//
//  AQSynth.m
//  Thumbafon
//
//  Created by Chris Lavender on 1/30/11.
//  Copyright 2011 Gnarly Dog Music. All rights reserved.
//
#include "math.h"

#import "AQSynth.h"
#import "Voice.h"

#if REVERB
#import "freeverb.h"
#endif

@interface AQSynth ()<VoiceDelegate> {
    Float64 _maxNoteAmp;
}

@property (nonatomic) NSArray *voiceArray;
@end

@implementation AQSynth
@synthesize volume = _volume;

- (NSArray *)voiceArray {
    if (!_voiceArray) {
        _voiceArray = @[];
    }
    
    return _voiceArray;
}

- (void)setVoiceClass:(Class)voiceClass {
    _voiceClass = voiceClass;
    self.voiceArray = @[];
}

- (void)setVolume:(UInt16)volume {
    if (_volume != volume) {
        _volume = volume;
        
        if (_volume > 100) {
            _volume = 100;
        }
        
        Float64 amp = _volume * 0.01;
        //amp = log10f(amp);
        NSLog(@"_volume: %d  amp: %f", _volume, amp);
        [self volumeLevel:amp];
    }
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
#if REVERB
        Reverb_Init();
        Reverb_SetRoomSize(0,0.5);
        Reverb_SetDamp(0,0.5);
        Reverb_SetWet(0,0.5);
        Reverb_SetDry(0,0.5);
#endif
    }
    return self;
}

#if REVERB
-(void)dealloc {
	Reverb_Release();
}
#endif

-(void)fillAudioBuffer:(Float64 *)buffer numFrames:(UInt32)num_frames {
//    if (self.changingSound) return;
    for (Voice *voice in self.voiceArray) {
        [voice getSamplesForFreq:buffer numSamples:num_frames];
    }
#if REVERB
	revmodel_process(buffer,num_frames,1);
#endif
}

- (Float64)maxNoteAmp {
    return _maxNoteAmp;
}

- (Voice *)addVoiceToVoiceArray {
    _maxNoteAmp = MAX_AMP / (self.voiceArray.count + 1);
    
    Voice *voice = [[self.voiceClass alloc] initWithDelegate:self];
    self.voiceArray = [self.voiceArray arrayByAddingObject:voice];
    
    return voice;
}

#pragma mark - monophonic methods
- (void)midiNoteOn:(NSInteger)noteNum {
    Voice *voice = self.voiceArray.firstObject;
    
    if (!voice) {
        voice = [self addVoiceToVoiceArray];
    }
    
    voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
    [voice on];
}

- (void)changeMidiNoteToNoteNum:(NSInteger)noteNum {
    Voice *voice = self.voiceArray.firstObject;
    voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
}

- (void)midiNoteOff:(NSInteger)noteNum {
    Voice *voice = self.voiceArray.firstObject;
    voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
    [voice off];
}

#pragma mark - polyphonic methods
- (void)midiNoteOn:(NSInteger)noteNum atVoiceIndex:(NSInteger)voiceIndex {
    Voice *voice;
    
    if (voiceIndex >= self.voiceArray.count) {
        voice = [self addVoiceToVoiceArray];
    
    } else {
        voice = self.voiceArray[voiceIndex];
    }
    
    voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
    [voice on];
}

- (void)changeMidiNoteToNoteNum:(NSInteger)noteNum atVoiceIndex:(NSInteger)voiceIndex {
    Voice *voice = self.voiceArray[voiceIndex];
    voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
}

- (void)midiNoteOff:(NSInteger)noteNum atVoiceIndex:(NSInteger)voiceIndex {
    Voice *voice = self.voiceArray[voiceIndex];
    voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
    [voice off];
}

- (void)killAll {
    [self.voiceArray makeObjectsPerformSelector:@selector(off)];
}

@end

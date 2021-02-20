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

@property (nonatomic) NSDictionary *voiceDict;
@end

@implementation AQSynth
@synthesize volume = _volume;

- (void)createNewVoiceDictionaryWithMidiNotes:(NSArray *)midiNoteNums {
    NSMutableDictionary *tempVoiceDict = [NSMutableDictionary dictionaryWithCapacity:midiNoteNums.count];
    for (NSNumber *noteNum in midiNoteNums) {
        Voice *voice = [[self.voiceClass alloc] initWithDelegate:self];
        voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
        tempVoiceDict[noteNum] = voice;
    }
    
    self.voiceDict = [NSDictionary dictionaryWithDictionary:tempVoiceDict];
}

- (void)setVoiceClass:(Class)voiceClass {
    _voiceClass = voiceClass;
    self.voiceDict = @{};
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
    for (Voice *voice in self.voiceDict.allValues) {
        [voice getSamplesForFreq:buffer numSamples:num_frames];
    }
#if REVERB
	revmodel_process(buffer,num_frames,1);
#endif
}

- (Float64)maxNoteAmp {
    return _maxNoteAmp;
}

- (void)calculateMaxNoteAmp {
    UInt16 numPlayingVoices = 1;
    
    for (Voice *existingVoice in self.voiceDict.allValues) {
        if (existingVoice.isOn) {
            numPlayingVoices += 1;
        }
    }
        
    _maxNoteAmp = MAX_AMP / numPlayingVoices;
    
}

- (void)midiNoteOn:(NSNumber *)noteNum {
    [self calculateMaxNoteAmp];
    [self.voiceDict[noteNum] on];
}

- (void)changeMidiNoteToNoteNum:(NSNumber *)noteNum {
//    Voice *voice = self.voiceArray.firstObject;
}

- (void)midiNoteOff:(NSNumber *)noteNum {
    [self calculateMaxNoteAmp];
    [self.voiceDict[noteNum] off];
}

- (void)killAll {
    [self.voiceDict.allValues makeObjectsPerformSelector:@selector(off)];
    [self calculateMaxNoteAmp];
}

@end

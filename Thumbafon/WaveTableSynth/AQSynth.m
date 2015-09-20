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
// #import "freeverb.h"

@interface AQSynth ()
@property (nonatomic) NSArray *voiceArray;
@end

@implementation AQSynth
@synthesize volume = _volume;

- (UInt16)volume {
    return _volume;
}

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
        
        for (int i = 0; i < kNumberVoices; ++i) {
            
            if (_volume > 100) {
                _volume = 100;
            }
            
            Float64 amp = _volume * 0.01;
            //amp = log10f(amp);
            NSLog(@"_volume: %d  amp: %f", _volume, amp);
            [self volumeLevel:amp];
        }
    }
}

-(void)dealloc {
	
//	Reverb_Release();
}

-(void)fillAudioBuffer:(Float64 *)buffer numFrames:(UInt32)num_frames {
//    if (self.changingSound) return;
    for (Voice *voice in self.voiceArray) {
        [voice getSamplesForFreq:buffer numSamples:num_frames];
    }

//	revmodel_process(buffer,num_samples,1);

}

#pragma mark - monophonic methods
- (void)midiNoteOn:(NSInteger)noteNum {
    if (self.voiceArray.count == 0) {
        self.voiceArray = [self.voiceArray arrayByAddingObject:[self.voiceClass new]];
    }
    
    Voice *voice = self.voiceArray[0];
    voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
    [voice on];
}

- (void)changeMidiNoteToNoteNum:(NSInteger)noteNum {
    Voice *voice = self.voiceArray[0];
    voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
}

- (void)midiNoteOff:(NSInteger)noteNum {
    Voice *voice = self.voiceArray[0];
    voice.freq = [Voice noteNumToFreq:(UInt8)noteNum];
    [voice off];
}

#pragma mark - polyphonic methods
- (void)midiNoteOn:(NSInteger)noteNum atVoiceIndex:(NSInteger)voiceIndex {
    if (voiceIndex >= self.voiceArray.count) {
        self.voiceArray = [self.voiceArray arrayByAddingObject:[self.voiceClass new]];
    }
    Voice *voice = self.voiceArray[voiceIndex];
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




@end

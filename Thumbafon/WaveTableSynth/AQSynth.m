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

@implementation AQSynth

- (UInt16)volume {
    return _volume;
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
	
    for (UInt8 i = 0; i < kNumberVoices; i++) {
        
        if (!changingSound && voice[i] != nil) {
            [voice[i] getSamplesForFreq:buffer numSamples:num_frames];
        }
    }
//	revmodel_process(buffer,num_samples,1);

}

#pragma mark - monophonic methods
- (void)midiNoteOn:(int)noteNum {
    voice[0].freq = [Voice noteNumToFreq:(UInt8)noteNum];
    [voice[0] on];
}

- (void)changeMidiNoteToNoteNum:(int)noteNum {
    voice[0].freq = [Voice noteNumToFreq:(UInt8)noteNum];
}

- (void)midiNoteOff:(int)noteNum {
    for (int i = 0 ; i < kNumberVoices; ++i) {
        voice[i].freq = [Voice noteNumToFreq:(UInt8)noteNum];
        [voice[i] off];
    }
}

#pragma mark - polyphonic methods
- (void)midiNoteOn:(int)noteNum atVoiceIndex:(int)voiceIndex {
    voice[voiceIndex].freq = [Voice noteNumToFreq:(UInt8)noteNum];
    [voice[voiceIndex] on];

}

- (void)changeMidiNoteToNoteNum:(int)noteNum atVoiceIndex:(int)voiceIndex {
    voice[voiceIndex].freq = [Voice noteNumToFreq:(UInt8)noteNum];

}

- (void)midiNoteOff:(int)noteNum atVoiceIndex:(int)voiceIndex {
    for (int i = 0 ; i < kNumberVoices; ++i) {
        voice[i].freq = [Voice noteNumToFreq:(UInt8)noteNum];
        [voice[i] off];
    }
}




@end

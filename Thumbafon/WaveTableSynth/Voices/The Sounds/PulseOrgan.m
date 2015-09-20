//
//  PulseOrgan.m
//  Thumbafon
//
//  Created by Chris Lavender on 2/4/11.
//  Copyright 2011 Gnarly Dog Music. All rights reserved.
//

#import "PulseOrgan.h"
#import "AQPlayer.h"

@implementation PulseOrgan

- (instancetype)initWithDelegate:(id<VoiceDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    if (self) {

        //Create WaveTable
        for (UInt32 i = 0; i < kAudioDataByteSize; i++) {
            
            _table[i] = 0;
            _theta = (Float64)i / kAudioDataByteSize;
            
            for (UInt8 j = 1; j <= 5; j += 1) {
                _table[i] += sin(j * _theta * 2. * M_PI) * [self.delegate maxNoteAmp];
            }
            _table[i] = _table[i] * [self.delegate maxNoteAmp];
        }
        
        //Set Envelope Settings
        _attack = kSR * 0.01;
        _release = kSR * 0.05;
        _sustain = 1.0;

    }
    return self;
}

@end

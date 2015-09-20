//
//  SinePiano.m
//  Thumbafon
//
//  Created by Chris Lavender on 2/4/11.
//  Copyright 2011 Gnarly Dog Music. All rights reserved.
//

#import "SinePiano.h"
#import "AQPlayer.h"

@implementation SinePiano

- (instancetype)initWithDelegate:(id<VoiceDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    if (self) {
        //Create WaveTable
        for (UInt32 i = 0; i < kAudioDataByteSize; i++) {
            
            _table[i] = 0;
            _theta = (Float64)i / kAudioDataByteSize;
            _table[i] = [self.delegate maxNoteAmp] * sin(_theta * 2. * M_PI);
        }
        
        //Set Envelope Settings
        _attack = kSR * 0.001;
        _release = kSR * 0.01;
        _sustain = 0.9;
        
    }
    return self;
}

@end

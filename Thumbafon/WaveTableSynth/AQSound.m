//
//  AQSound.m
//  Thumbafon
//
//  Created by Chris Lavender on 2/4/11.
//  Copyright 2011 Gnarly Dog Music. All rights reserved.
//

#import "AQSound.h"
#import "SinePiano.h"
#import "PulseOrgan.h"
#import "SquareStrings.h"
#import "SawBrass.h"
#import "TriangleFlute.h"

@implementation AQSound

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.voiceClass = [SinePiano class];
    }
    return self;
}

- (void)setSoundType:(SoundType)newSoundType {
    if (_soundType != newSoundType) {
        _soundType = newSoundType;
        
        switch (_soundType) {
            case Organ:
                self.voiceClass = [PulseOrgan class];
                break;
            case Brass:
                self.voiceClass = [SawBrass class];
                break;
            case Strings:
                self.voiceClass = [SquareStrings class];
                break;
            case Flute:
                self.voiceClass = [TriangleFlute class];
                break;
                
            default:
                self.voiceClass = [SinePiano class];
                break;
        }
    }
}

@end

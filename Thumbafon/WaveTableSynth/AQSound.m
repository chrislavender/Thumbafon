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

- (id)init {
    self = [super init];
    
    if (self) {
        for (UInt8 i = 0; i < kNumberVoices; i++) {
            voice[i] = [[SinePiano alloc] init];
        }
    }
    return self;
}

- (void)setSoundType:(SoundType)newSoundType {
    if (_soundType != newSoundType) {
        _soundType = newSoundType;
        changingSound = YES;
        
        switch (_soundType) {
            case Organ:
                for (UInt8 i = 0; i < kNumberVoices; i++) voice[i] = [[PulseOrgan alloc] init];
                break;
            case Brass:
                for (UInt8 i = 0; i < kNumberVoices; i++) voice[i] = [[SawBrass alloc] init];
                break;
            case Strings:
                for (UInt8 i = 0; i < kNumberVoices; i++) voice[i] = [[SquareStrings alloc] init];
                break;
            case Flute:
                for (UInt8 i = 0; i < kNumberVoices; i++) voice[i] = [[TriangleFlute alloc] init];
                break;
                
            default:
                for (UInt8 i = 0; i < kNumberVoices; i++) voice[i] = [[SinePiano alloc] init];
                break;
        }
        
        changingSound = NO;
    }
}

@end

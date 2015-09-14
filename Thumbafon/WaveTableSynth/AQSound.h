//
//  AQSound.h
//  Thumbafon
//
//  Created by Chris Lavender on 2/4/11.
//  Copyright 2011 Gnarly Dog Music. All rights reserved.
//

//This class determines what sound will be alloc/inited

#import <Foundation/Foundation.h>
#import "AQSynth.h"

typedef NS_ENUM(NSUInteger, SoundType) {
    EPiano = 0,
    Organ,
    Brass,
    Strings,
    Flute
};

@interface AQSound : AQSynth

@property (nonatomic) SoundType soundType;

@end


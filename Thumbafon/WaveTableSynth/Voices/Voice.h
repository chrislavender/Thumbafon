//
//  Voice.h
//  Thumbafon
//
//  Created by Chris Lavender on 1/30/11.
//  Copyright 2011 Gnarly Dog Music. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQPlayer.h"

@protocol VoiceDelegate <NSObject>
- (Float64)maxNoteAmp;
@end

@interface Voice : NSObject {
	
    Float64 _amplitude;
	
	Float64 _attack;
	Float64 _sustain;
	Float64 _release;
	Float64 _ampDelta;
    
    Float64 _theta;
	Float64 _deltaTheta;
	Float64 _freq;
	
	Float64 _table[kAudioDataByteSize];
}

- (instancetype)initWithDelegate:(id<VoiceDelegate>)delegate;

- (void)on;
- (void)off;

- (Float64)getEnvelope;

@property (nonatomic) Float64 freq;
@property (nonatomic) BOOL isOn;
@property (nonatomic, weak) id<VoiceDelegate> delegate;

+ (Float64)noteNumToFreq:(UInt8)note_num;

- (void)getSamplesForFreq:(Float64 *)buffer numSamples:(UInt32)num_samples;
- (Float64)getWaveTable:(Float64)index;


@end

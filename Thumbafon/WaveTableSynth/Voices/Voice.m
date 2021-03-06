//
//  Voice.m
//  Thumbafon
//
//  Created by Chris Lavender on 1/30/11.
//  Copyright 2011 Gnarly Dog Music. All rights reserved.
//

#import "Voice.h"

@implementation Voice
@synthesize freq = _freq;

- (instancetype)initWithDelegate:(id<VoiceDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)on {
    _ampDelta = 1. / _attack;
//    _isOn = YES;
}

- (void)off {
    _ampDelta = -1. / _release;
//    _isOn = NO;
}

- (Float64)getEnvelope {
    _amplitude += _ampDelta;
    //1.0 = 1 second)
    if (_amplitude >= 1.0) {
        _amplitude = _sustain;
        _ampDelta = 0.;
    }
    else if (_amplitude <= 0.0) {
        _amplitude = 0.;
        _ampDelta = 0.;
    }
    return _amplitude;
}

+ (Float64)noteNumToFreq:(UInt8)noteNum {
    return pow(2., (Float64)(noteNum - 69) / 12.) * 440.;
}

- (void)setFreq:(double)val; {
    _freq = val;
    _deltaTheta = _freq / kSR;
}

- (void)getSamplesForFreq:(Float64 *)buffer numSamples:(UInt32)num_samples {
    for (UInt32 i = 0; i < num_samples; ++i) {
        buffer[i] += [self.delegate maxNoteAmp] * [self getWaveTable:_theta] * [self getEnvelope];
        _theta += _deltaTheta;
    }
}

- (Float64)getWaveTable:(Float64)index {
    UInt32 i = (UInt32)(index * kAudioDataByteSize);
    i %= kAudioDataByteSize;
    return _table[i];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"freq: %f, ampDelta: %f, amplitude: %f, isOn: %@", _freq,_ampDelta, _amplitude, _isOn ? @"YES" : @"NO"];
}
@end

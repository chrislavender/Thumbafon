//
//  AQPlayer.m
//  Thumbafon
//
//  Created by Chris Lavender on 4/7/10.
//  Copyright 2010 Gnarly Dog Music. All rights reserved.
//

#import "AQPlayer.h"

void AQBufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inAQBuffer) {

    AQPlayer *aqp = (__bridge AQPlayer *)inUserData;

    const SInt32 numFrames = (inAQBuffer->mAudioDataBytesCapacity) / sizeof(SInt16);
    Float64 sampleBuffer[numFrames];

    memset(sampleBuffer, 0, sizeof(Float64) * numFrames);
    [aqp fillAudioBuffer:sampleBuffer numFrames:(UInt32)numFrames];

    for (UInt32 i = 0; i < numFrames; i++) {
        Float64 sample = sampleBuffer[i];
        sample = sample > MAX_AMP ? MAX_AMP : sample < -MAX_AMP ? -MAX_AMP : sample;
        ((SInt16 *)inAQBuffer->mAudioData)[i] = (SInt16)(sample * (SInt16)0x7FFF);
    }

    inAQBuffer->mAudioDataByteSize = kAudioDataByteSize;
    inAQBuffer->mPacketDescriptionCount = 0;
    AudioQueueEnqueueBuffer(inAQ, inAQBuffer, 0, nil);
}


@interface AQPlayer () {
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef mQueue;
    AudioQueueBufferRef mBuffers[kNumberBuffers];
}
@end

@implementation AQPlayer

- (void)dealloc {
    [self stop];
}

- (void)newAQ {
    mDataFormat.mSampleRate = kSR;
    mDataFormat.mFormatID = kAudioFormatLinearPCM;
    mDataFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    mDataFormat.mBytesPerPacket = sizeof(SInt16);
    mDataFormat.mFramesPerPacket = 1;
    mDataFormat.mBytesPerFrame = sizeof(SInt16);
    mDataFormat.mChannelsPerFrame = 1;
    mDataFormat.mBitsPerChannel = 16;

    OSStatus result = AudioQueueNewOutput(&mDataFormat, AQBufferCallback, (__bridge void *)(self), nil, nil, 0,
                                          &mQueue);

    if (result != noErr)
        printf("AudioQueueNewOutput %d\n", (int)result);

    for (UInt8 i = 0; i < kNumberBuffers; ++i) {
        result = AudioQueueAllocateBuffer(mQueue, kAudioDataByteSize, &mBuffers[i]);
        if (result != noErr)
            printf("AudioQueueAllocateBuffer %d\n", (int)result);
    }
}

- (OSStatus)start {
    // if we have no queue, create one now
    if (mQueue == nil)
        [self newAQ];

    // prime the queue with some data before starting
    for (UInt8 i = 0; i < kNumberBuffers; ++i)
        AQBufferCallback((__bridge void *)(self), mQueue, mBuffers[i]);

    OSStatus result = AudioQueueStart(mQueue, nil);

    return result;
}


- (OSStatus)stop {
    OSStatus result = AudioQueueStop(mQueue, true);

    return result;
}


- (OSStatus)volumeLevel:(float)level {
    OSStatus result = AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, level);
    if (result != noErr) {
        NSLog(@"AudioQueueSetParameter returned %d when setting the volume.", (int)result);
    }

    return result;
}

- (void)fillAudioBuffer:(Float64 *)buffer numFrames:(UInt32)numFrames {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

@end

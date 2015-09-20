//
//  AQSynth.h
//  Thumbafon
//
//  Created by Chris Lavender on 1/30/11.
//  Copyright 2011 Gnarly Dog Music. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQPlayer.h"


@interface AQSynth : AQPlayer
@property (nonatomic) Class voiceClass;
@property (nonatomic) UInt16 volume;


- (void)killAll;

#pragma mark - monophonic methods

- (void)midiNoteOn:(NSInteger)noteNum;

- (void)changeMidiNoteToNoteNum:(NSInteger)noteNum;

- (void)midiNoteOff:(NSInteger)noteNum;

#pragma mark - polyphonic methods

- (void)midiNoteOn:(NSInteger)noteNum atVoiceIndex:(NSInteger)voiceIndex;

- (void)changeMidiNoteToNoteNum:(NSInteger)noteNum atVoiceIndex:(NSInteger)voiceIndex;

- (void)midiNoteOff:(NSInteger)noteNum atVoiceIndex:(NSInteger)voiceIndex;

@end

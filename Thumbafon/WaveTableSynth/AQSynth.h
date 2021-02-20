//
//  AQSynth.h
//  Thumbafon
//
//  Created by Chris Lavender on 1/30/11.
//  Copyright 2011 Gnarly Dog Music. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQPlayer.h"

#define REVERB 0

@interface AQSynth : AQPlayer
@property (nonatomic) Class voiceClass;
@property (nonatomic) UInt16 volume;

- (void)createNewVoiceDictionaryWithMidiNotes:(NSArray *)midiNoteNums;

- (void)killAll;

- (void)midiNoteOn:(NSNumber *)noteNum;

- (void)changeMidiNoteToNoteNum:(NSNumber *)noteNum;

- (void)midiNoteOff:(NSNumber *)noteNum;

@end

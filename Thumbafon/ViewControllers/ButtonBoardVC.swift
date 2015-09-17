//
//  ButtonBoardVC.swift
//  Thumbafon
//
//  Created by Chris Lavender on 9/12/15.
//  Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit

class ButtonBoardVC: UIViewController, ButtonsViewDelegate {

    struct NoteVoice {
        var noteNum : Int
        var voiceIndex : Int
    }
    
    private let aqPlayer = AQSound()
    private let baseScale = Scale.baseNoteNumbers()
    private let buttonView = ButtonsView(frame:CGRectZero)

    private var buttToVoiceMap = [Int : NoteVoice]()
    
    let kBaseOctaveOffset = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aqPlayer.start()
        aqPlayer.volume = 100
        aqPlayer.soundType = SoundType.EPiano
        
        buttonView.delegate = self;
        buttonView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.view.addSubview(buttonView)
        
        let bindings = ["buttonView": buttonView]
        let hortConstrants = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[buttonView]|",
            options: NSLayoutFormatOptions.allZeros,
            metrics: nil,
            views: bindings
        )
        
        let vertConstrants = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[buttonView]|",
            options: NSLayoutFormatOptions.allZeros,
            metrics: nil,
            views: bindings
        )

        self.view.addConstraints(hortConstrants)
        self.view.addConstraints(vertConstrants)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didActivateButtonAtIndex(buttonIndex: Int) {
        let noteIndex = buttonIndex % baseScale.count
        let rawNoteNum = Int(baseScale[noteIndex])
        let octaveNumber = buttonIndex == 0 ? kBaseOctaveOffset : Int(buttonIndex / baseScale.count) + kBaseOctaveOffset
        let transposedNoteNum = rawNoteNum + (12 * octaveNumber)
        let noteVoice = NoteVoice(noteNum:transposedNoteNum, voiceIndex: buttToVoiceMap.count)
        aqPlayer.midiNoteOn(noteVoice.noteNum, atVoiceIndex:noteVoice.voiceIndex)
        buttToVoiceMap[buttonIndex] = NoteVoice(noteNum:noteVoice.noteNum, voiceIndex: noteVoice.voiceIndex)
    }
    
    func didDeactivateButtonAtIndex(buttonIndex: Int) {
        if let noteVoice : NoteVoice = buttToVoiceMap[buttonIndex] {
            aqPlayer.midiNoteOff(noteVoice.noteNum, atVoiceIndex: noteVoice.voiceIndex)
            buttToVoiceMap.removeValueForKey(buttonIndex)
        }
    }
}


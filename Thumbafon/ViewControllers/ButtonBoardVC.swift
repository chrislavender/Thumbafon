//
//  ButtonBoardVC.swift
//  Thumbafon
//
//  Created by Chris Lavender on 9/12/15.
//  Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit

class ButtonBoardVC: UIViewController, ButtonsViewDelegate {

    private let aqPlayer = AQSound()
    private let baseScale = Scale.baseNoteNumbers()
    private let buttonView = ButtonsView(frame:CGRect.zero)
    
    let kBaseOctaveOffset = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aqPlayer.start()
        aqPlayer.volume = 100
        aqPlayer.soundType = SoundType.EPiano
        
        buttonView.delegate = self;
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(buttonView)
        
        let bindings = ["buttonView": buttonView]
        let hortConstrants = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[buttonView]|",
            options: [],
            metrics: nil,
            views: bindings
        )
        
        let vertConstrants = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[buttonView]|",
            options: [],
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
    
    func midiNoteNumForButtonAtIndex(buttonIndex: Int, totalButtons: Int) -> Int {
        let noteIndex = buttonIndex % baseScale.count
        let rawNoteNum = Int(baseScale[noteIndex])
        let octaveOffset = (totalButtons > 12) ? kBaseOctaveOffset : kBaseOctaveOffset + 1
        let octaveNumber = buttonIndex == 0 ? octaveOffset : Int(buttonIndex / baseScale.count) + octaveOffset
        return rawNoteNum + (12 * octaveNumber)
    }
    
    func didActivateButtonWithNoteNum(noteNum: Int, touchIndex: Int) {
        aqPlayer.midiNote(on: noteNum, atVoiceIndex:touchIndex)
    }
    
    func didChangeButton(toNoteNum noteNum: Int, touchIndex: Int) {
        aqPlayer.changeMidiNote(toNoteNum: noteNum, atVoiceIndex: touchIndex)
    }
    
    func didDeactivateButtonWithNoteNum(noteNum: Int, touchIndex: Int) {
        aqPlayer.midiNoteOff(noteNum, atVoiceIndex: touchIndex)
    }
    
    func killAllNotes() {
        aqPlayer.killAll()
    }
}

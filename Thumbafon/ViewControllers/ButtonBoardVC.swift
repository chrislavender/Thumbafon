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
    private let buttonView = ButtonsView(frame:CGRectZero)
    
    let kBaseOctaveOffset = 4
    
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
    
    func midiNoteNumForButtonAtIndex(buttonIndex: Int) -> Int {
        let noteIndex = buttonIndex % baseScale.count
        let rawNoteNum = Int(baseScale[noteIndex])
        let octaveNumber = buttonIndex == 0 ? kBaseOctaveOffset : Int(buttonIndex / baseScale.count) + kBaseOctaveOffset
        return rawNoteNum + (12 * octaveNumber)
    }
    
    func didActivateButtonWithNoteNum(noteNum: Int, touchIndex: Int) {
        aqPlayer.midiNoteOn(noteNum, atVoiceIndex:touchIndex)
    }
    
    func didChangeButton(toNoteNum noteNum: Int, touchIndex: Int) {
        aqPlayer.changeMidiNoteToNoteNum(noteNum, atVoiceIndex: touchIndex)
    }
    
    func didDeactivateButtonWithNoteNum(noteNum: Int, touchIndex: Int) {
        aqPlayer.midiNoteOff(noteNum, atVoiceIndex: touchIndex)
    }
}

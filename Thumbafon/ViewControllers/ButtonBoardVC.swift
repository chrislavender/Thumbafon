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
        
        view.addSubview(buttonView)
        
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

        view.addConstraints(hortConstrants)
        view.addConstraints(vertConstrants)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateNumberOfButtonsForButtonView(buttonView: ButtonsView) -> (ButtonGridDefinition)? {
        
        let size = buttonView.frame.size
        
        if size.width == 0.0 || size.height == 0.0 {
            return nil
        }
        
        var minButtWidth : CGFloat = 0.0
        var minButtHeight : CGFloat = 0.0
        
        let currentTraits = traitCollection
        
        switch currentTraits.horizontalSizeClass {
        case .compact:
            minButtWidth = buttonView.minCompactButtonSize.width
                break;
        case .regular:
            minButtWidth = buttonView.minRegularButtonSize.width
                break;
        case .unspecified:
            minButtWidth = buttonView.minCompactButtonSize.width
                break;
        @unknown default:
            fatalError()
        }
        
        switch currentTraits.verticalSizeClass {
        case .compact:
            minButtHeight = buttonView.minCompactButtonSize.height
                break;
        case .regular:
            minButtHeight = buttonView.minRegularButtonSize.height
                break;
        case .unspecified:
            minButtHeight = buttonView.minCompactButtonSize.height
                break;
        @unknown default:
            fatalError()
        }
        
        let numCols = Int(size.width / minButtWidth)
        let numRows = Int(size.height / minButtHeight)
        let width = size.width / CGFloat(numCols)
        let height = size.height / CGFloat(numRows)
        
        return (numRows, numCols, width, height)
    }
    
    // this takes a "base scale" which is a model of intervals and translates
    // into noteNumbers accounting for multiple octaves if applicable.
    func calculateMidiNoteNumbersFor(buttonView: ButtonsView) {
        var buttonIndex = 0
        
        var midiNoteNumbers = [NSNumber]()

        for button in buttonView.slickButtons {
            let noteIndex = buttonIndex % baseScale.count
            let rawNoteNum = Int(baseScale[noteIndex])
            let octaveOffset = (buttonView.slickButtons.count > 12) ? kBaseOctaveOffset : kBaseOctaveOffset + 1
            let octaveNumber = buttonIndex == 0 ? octaveOffset : Int(buttonIndex / baseScale.count) + octaveOffset
            
            let midiNoteNum = rawNoteNum + (12 * octaveNumber)
            
            midiNoteNumbers.append(NSNumber(value: rawNoteNum))

            button.tag = midiNoteNum
            button.setTitle("\(button.tag)", for: UIControl.State.normal)
            buttonIndex += 1
        }
        
        aqPlayer.createNewVoiceDictionary(withMidiNotes: midiNoteNumbers)
    }
    
    func didActivateButtonWithNoteNum(noteNum: Int) {
        aqPlayer.midiNote(on: noteNum as NSNumber)
    }
    
    func didChangeButton(toNoteNum noteNum: Int) {
        aqPlayer.changeMidiNote(toNoteNum: noteNum as NSNumber)
    }
    
    func didDeactivateButtonWithNoteNum(noteNum: Int) {
        aqPlayer.midiNoteOff(noteNum as NSNumber)
    }
    
    func killAllNotes() {
        aqPlayer.killAll()
    }
}

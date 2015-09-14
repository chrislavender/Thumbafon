//
//  ButtonBoardVC.swift
//  Thumbafon
//
//  Created by Chris Lavender on 9/12/15.
//  Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit

class ButtonBoardVC: UIViewController, ButtonsViewDelegate {

    let aqPlayer = AQSound()

    override func viewDidLoad() {
        super.viewDidLoad()
        aqPlayer.start()
        aqPlayer.volume = 100
        aqPlayer.soundType = SoundType.EPiano
        
        let buttonView = ButtonsView.init(frame:CGRectZero)
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
        aqPlayer.midiNoteOn(76)
    }
    
    func didDeactivateButtonAtIndex(buttonIndex: Int) {
        aqPlayer.midiNoteOff(76)
    }
}


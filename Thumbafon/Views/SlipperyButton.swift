//
//  SlipperyButton.swift
//  Thumbafon
//
//  Created by Chris Lavender on 9/12/15.
//  Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit

class SlipperyButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.userInteractionEnabled = true;
        self.multipleTouchEnabled = true;
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.nextResponder()?.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.nextResponder()?.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.nextResponder()?.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        self.nextResponder()?.touchesCancelled(touches, withEvent: event)
    }
    
}
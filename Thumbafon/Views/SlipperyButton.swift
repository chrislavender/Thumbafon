//
//  SlipperyButton.swift
//  Thumbafon
//
//  Created by Chris Lavender on 9/12/15.
//  Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit

class SlipperyButton: UIView {
    
    var highlighted = false {
        didSet {
            self.backgroundColor =  highlighted ? selectedColor : defaultColor
            
            if highlighted == true {
                self.backgroundColor = selectedColor

                if let img = selectedFrameImage {
                    frameImageView.image = img
                }
            } else {
                self.backgroundColor = defaultColor
                
                if let img = defaultFrameImage {
                    frameImageView.image = img
                }
            }
        }
    }
    
    var defaultColor = UIColor() {
        didSet {
            var h:CGFloat = 0.0, s:CGFloat = 0.0
            let cCopy = defaultColor.getHue(&h, saturation: &s, brightness:nil, alpha:nil)
            selectedColor = UIColor(hue: h, saturation: s, brightness: 0.7, alpha: 1.0)
            self.backgroundColor = defaultColor
        }
    }
    
    var defaultFrameImage : UIImage? {
        didSet {
            self.frameImageView.image = defaultFrameImage
        }
    }
    
    var selectedFrameImage : UIImage?
    
    private var frameImageView = UIImageView()
    
    var selectedColor = UIColor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(frameImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        frameImageView.frame = self.bounds
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
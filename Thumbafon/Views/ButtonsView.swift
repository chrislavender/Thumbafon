//
// Created by Chris Lavender on 9/12/15.
// Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit

protocol ButtonsViewDelegate : class {
    func didActivateButtonAtIndex(buttonIndex : Int)
    func didDeactivateButtonAtIndex(buttonIndex : Int)
}

class ButtonsView: UIView {

    weak var delegate: ButtonsViewDelegate?
    
    private let numButtons: Int = 16
    private let minButtonSize: CGSize = CGSizeMake(128.0, 145.0)
    private let maxButtonSize: CGSize = CGSizeMake(120.0, 145.0)
    private let buttColorNames = ["red", "pink", "purple", "blue", "aqua", "green", "seafoam", "yellow"]

    private var touchDict = [NSValue : SlipperyButton]()
    private var slickButtons = [SlipperyButton]()
    private var buttWidthConstraint = NSLayoutConstraint()
    private var buttHeightConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createButtons(frame)
        self.backgroundColor = UIColor.blackColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        deactivateAllButtons()
        return true;
    }
    
    private func createButtons(frame: CGRect) {
        // Create slickButton array
        var x : CGFloat = 0.0
        var y : CGFloat = minButtonSize.height
        
        for buttonNum in 0...numButtons {
            
            let buttonRect = CGRectMake(x, y, minButtonSize.width, minButtonSize.height);
            
            let newButton = SlipperyButton.init(frame: buttonRect)
            newButton.tag = buttonNum
            let nIndex = "\(buttonNum)"
            newButton.setTitle(nIndex, forState: UIControlState.Normal)
            
            self.addSubview(newButton)
            
            x += minButtonSize.width;
            
            let halfway : Int = (numButtons - 1) / 2
            
            if buttonNum == halfway {
                x = 0
                y = 0
            
            } else if buttonNum > halfway {
                y = 0
            }
            
            var index = buttonNum % buttColorNames.count
            let colorName = buttColorNames[index]

            newButton.setBackgroundImage(UIImage(named: "\(colorName)2"), forState:UIControlState.Normal)
            newButton.setBackgroundImage(UIImage(named: "\(colorName)1"), forState:UIControlState.Highlighted)
            
            slickButtons.append(newButton)
        }
    }
    
    private func deactivateAllButtons() {
        for button in slickButtons {
            let buttonIndex : Int = button.titleLabel!.text!.toInt()!
            self.delegate?.didDeactivateButtonAtIndex(buttonIndex)
            button.highlighted = false;
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let touchPoint = touch.locationInView(self)
        
        for button in slickButtons {
            if CGRectContainsPoint(button.frame, touchPoint) && !button.highlighted {
                button.highlighted = true;
                let buttonIndex : Int = button.tag
                self.delegate?.didActivateButtonAtIndex(buttonIndex)
                let key = NSValue.init(nonretainedObject: touch)
                touchDict[key] = button
                break;
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let key = NSValue.init(nonretainedObject: touch)
        
        if let movedButton = touchDict[key] as SlipperyButton! {
            let touchPoint = touch.locationInView(self)
            
            // see if we slid outside of the currently selected button
            if movedButton.highlighted && !CGRectContainsPoint(movedButton.frame, touchPoint) {
                movedButton.highlighted = false;
                let buttonIndex : Int = movedButton.tag
                self.delegate?.didDeactivateButtonAtIndex(buttonIndex)
            }
            /*
            // TODO: find out where we are in the button?
            //the following tracks where in each button the touches are located (partial implementation)
            else if (movedButton.highlighted && CGRectContainsPoint(movedButton.frame, touchPoint)) {
            CGPoint buttonTouch = [touch locationInView:touch.view];
            double yVal = 1/buttonTouch.y;
            yVal = yVal > 0.8 ? 0.8 : yVal < 0.4 ? 0.4 : yVal;
            //NSLog(@"buttonTouch.x = %f, buttonTouch.y = %f", buttonTouch.x, buttonTouch.y);
            }
            */
            
            // see if we slid into another button
            for button in slickButtons {
                if(!movedButton.highlighted && CGRectContainsPoint(button.frame, touchPoint)) {
                    button.highlighted = true;
                    //TODO: turn note on
                    let buttonIndex : Int = movedButton.tag
                    self.delegate?.didActivateButtonAtIndex(buttonIndex)
                    let key = NSValue.init(nonretainedObject: touch)
                    touchDict[key] = button
                    break;
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let key = NSValue.init(nonretainedObject: touch)
        if let endedButton = touchDict[key] as SlipperyButton! {
            endedButton.highlighted = false
            let buttonIndex : Int = endedButton.tag
            self.delegate?.didDeactivateButtonAtIndex(buttonIndex)
        }
        touchDict.removeValueForKey(key)

    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        deactivateAllButtons()
    }
    
}

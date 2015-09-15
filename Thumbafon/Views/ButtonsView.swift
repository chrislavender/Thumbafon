//
// Created by Chris Lavender on 9/12/15.
// Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit

protocol ButtonsViewDelegate : class {
    func didActivateButtonAtIndex(buttonIndex : Int)
    func didDeactivateButtonAtIndex(buttonIndex : Int)
}

typealias ButtonGridDefinition = (
    numRows: Int, numCols: Int, buttWidth: CGFloat, buttHeight: CGFloat
)

class ButtonsView: UIView {

    weak var delegate: ButtonsViewDelegate?
    
    private let minButtonSize: CGSize = CGSizeMake(120.0, 130.0)
    private let buttColorNames = ["red", "pink", "purple", "blue", "aqua", "green", "seafoam", "yellow"]

    private var touchDict = [NSValue : SlipperyButton]()
    private var slickButtons = [SlipperyButton]()
    private var buttWidthConstraint = NSLayoutConstraint()
    private var buttHeightConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let gridDef = calculateNumberOfButtonsForViewSize(frame.size) {
            if slickButtons.count != gridDef.numRows * gridDef.numCols {
                manageButtons(frame, grid: gridDef)
            }
            
            var x : CGFloat = 0.0
            var y : CGFloat = CGRectGetHeight(self.bounds) - gridDef.buttHeight
            var colCount = 1
            
            for button in slickButtons {
                button.frame = CGRectMake(x, y, gridDef.buttWidth, gridDef.buttHeight);
                x += gridDef.buttWidth;
                colCount++
                
                if colCount > gridDef.numCols {
                    x = 0.0
                    y = CGRectGetMinY(button.frame) - gridDef.buttHeight
                    colCount = 1 // reset for next row
                }
            }
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        deactivateAllButtons()
        return true;
    }
    
    private func calculateNumberOfButtonsForViewSize(size: CGSize) -> (ButtonGridDefinition)? {
        
        if size.width == 0.0 || size.height == 0.0 {
            return nil
        }
        
        let numCols = Int(size.width / minButtonSize.width)
        let numRows = Int(size.height / minButtonSize.height)
        let width = size.width / CGFloat(numCols)
        let height = size.height / CGFloat(numRows)
        
        return (numRows, numCols, width, height)
    }
    
    private func manageButtons(frame: CGRect, grid: ButtonGridDefinition) {
        // Create slickButton array
        var numButtons = grid.numRows * grid.numCols
        var numButtsToManage = numButtons - slickButtons.count
        
        if numButtsToManage > 0 {
            // we need to add some buttons
            for buttonNum in 1...numButtsToManage {
                var colorIndex = (buttonNum - 1) % buttColorNames.count
                let colorName = buttColorNames[colorIndex]
                
                let newButton = SlipperyButton.buttonWithType(UIButtonType.Custom) as! SlipperyButton
                slickButtons.append(newButton)
                newButton.tag = slickButtons.count
                newButton.setTitle("\(slickButtons.count)", forState: UIControlState.Normal)
                newButton.setBackgroundImage(UIImage(named: "\(colorName)2"), forState:UIControlState.Normal)
                newButton.setBackgroundImage(UIImage(named: "\(colorName)1"), forState:UIControlState.Highlighted)
                self.addSubview(newButton)
                
            }
        
        } else if numButtsToManage < 0 {
            let targetButtCount = slickButtons.count + numButtsToManage
            for buttonIndex in reverse(0...(slickButtons.count - 1)) {
                let button = slickButtons[buttonIndex]
                button.removeFromSuperview()
                slickButtons.removeAtIndex(buttonIndex)
                if targetButtCount == slickButtons.count {
                    break;
                }
            }
        }
        // if the number to manage is zero then do nothing.
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
                let key = NSValue(nonretainedObject: touch)
                touchDict[key] = button
                break;
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let key = NSValue(nonretainedObject: touch)
        
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
                    let key = NSValue(nonretainedObject: touch)
                    touchDict[key] = button
                    break;
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let key = NSValue(nonretainedObject: touch)
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

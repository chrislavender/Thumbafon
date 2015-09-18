//
// Created by Chris Lavender on 9/12/15.
// Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit

protocol ButtonsViewDelegate : class {
    func didActivateButtonAtIndex(buttonIndex: Int)
    func didChangeButtonFromIndex(oldIndex: Int, toIndex newIndex: Int)
    func didDeactivateButtonAtIndex(buttonIndex: Int)
}

typealias ButtonGridDefinition = (
    numRows: Int, numCols: Int, buttWidth: CGFloat, buttHeight: CGFloat
)

class ButtonsView: UIView {

    weak var delegate: ButtonsViewDelegate?
    
    private let minButtonSize: CGSize = CGSizeMake(160.0, 180.0) // 120 & 130?
    private let buttColorNames = ["red", "pink", "purple", "blue", "aqua", "green", "seafoam", "yellow"]

    private(set) internal var slickButtons = [SlipperyButton]()
    private var touchDict = [NSValue : SlipperyButton]()
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
            for buttonNum in 0...numButtsToManage - 1 {
                var colorIndex = (buttonNum) % buttColorNames.count
                let colorName = buttColorNames[colorIndex]
                
                let newButton = SlipperyButton.buttonWithType(UIButtonType.Custom) as! SlipperyButton
                slickButtons.append(newButton)
                let noteIndex = slickButtons.count - 1
                newButton.tag = noteIndex
                newButton.setTitle("\(noteIndex)", forState: UIControlState.Normal)
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
    
    func deactivateAllButtons() {
        for button in slickButtons {
            button.highlighted = false;
            self.delegate?.didDeactivateButtonAtIndex(button.tag)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for item in touches {
            let touch = item as! UITouch
            let touchPoint = touch.locationInView(self)
            let button = self.hitTest(touchPoint, withEvent: UIEvent()) as! SlipperyButton
            if !button.highlighted {
                button.highlighted = true;
                self.delegate?.didActivateButtonAtIndex(button.tag)
                touchDict[NSValue(nonretainedObject: touch)] = button
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for item in touches {
            let touch = item as! UITouch
            let key = NSValue(nonretainedObject: touch)
            if let movedButton = touchDict[key] as SlipperyButton! {
                
                let touchPoint = touch.locationInView(self)
                let activeButton = self.hitTest(touchPoint, withEvent: UIEvent()) as! SlipperyButton
                
                // see if we slid outside of the currently selected button
                if movedButton !== activeButton {
                    // turn off the old
                    movedButton.highlighted = false;
                    // turn on the new
                    activeButton.highlighted = true;
                    // update the vc so it can change the pitch
                    self.delegate?.didChangeButtonFromIndex(movedButton.tag, toIndex: activeButton.tag)
                    // update the touch dictionary with the new active button
                    touchDict[key] = activeButton
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for item in touches {
            let touch = item as! UITouch
            let key = NSValue(nonretainedObject: touch)
            if let endedButton = touchDict[key] as SlipperyButton! {
                endedButton.highlighted = false
                self.delegate?.didDeactivateButtonAtIndex(endedButton.tag)
            }
            touchDict.removeValueForKey(key)
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        deactivateAllButtons()
    }
    
}

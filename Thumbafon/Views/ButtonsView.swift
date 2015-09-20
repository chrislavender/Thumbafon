//
// Created by Chris Lavender on 9/12/15.
// Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit
import ObjectiveC

// Declare a global var to produce a unique address as the assoc object handle
var UITouchIndexPropertyHandle: UInt8 = 0

extension UITouch {
    var touchIndex:Int {
        get {
            return (objc_getAssociatedObject(self, &UITouchIndexPropertyHandle) as? Int ?? nil)!
        }
        set {
            objc_setAssociatedObject(self, &UITouchIndexPropertyHandle, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
}

typealias ButtonGridDefinition = (
    numRows: Int, numCols: Int, buttWidth: CGFloat, buttHeight: CGFloat
)

protocol ButtonsViewDelegate : class {
    func midiNoteNumForButtonAtIndex(buttonIndex: Int) -> Int
    func didActivateButtonWithNoteNum(noteNum:Int, touchIndex: Int)
    func didChangeButton(toNoteNum noteNum: Int, touchIndex: Int)
    func didDeactivateButtonWithNoteNum(noteNum: Int, touchIndex: Int)
}

class ButtonsView: UIView {

    weak var delegate: ButtonsViewDelegate?
    
    private let minButtonSize: CGSize = CGSizeMake(160.0, 180.0) // 120 & 130?
    private let buttColorNames = ["red", "pink", "purple", "blue", "aqua", "green", "seafoam", "yellow"]

    private(set) internal var slickButtons = [SlipperyButton]()
    private var touchDict = [NSValue : SlipperyButton]()
    private var buttWidthConstraint = NSLayoutConstraint()
    private var buttHeightConstraint = NSLayoutConstraint()
    
    private var touchIndexes = [Int]()

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
                addButtons(frame, grid: gridDef)
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
    
    private func addButtons(frame: CGRect, grid: ButtonGridDefinition) {
        // Create slickButton array
        var numButtons = grid.numRows * grid.numCols
        var numButtsToCreate = numButtons - slickButtons.count
        
        if numButtsToCreate > 0 {
            // we need to add some buttons
            for buttonNum in 0...numButtsToCreate - 1 {
                var colorIndex = (buttonNum) % buttColorNames.count
                let colorName = buttColorNames[colorIndex]
                
                let newButton = SlipperyButton.buttonWithType(UIButtonType.Custom) as! SlipperyButton
                slickButtons.append(newButton)
                let noteIndex = slickButtons.count - 1
                
                if let _ = self.delegate {
                    newButton.tag = self.delegate!.midiNoteNumForButtonAtIndex(noteIndex)
                }
                
                newButton.setTitle("\(newButton.tag)", forState: UIControlState.Normal)
                newButton.setBackgroundImage(UIImage(named: "\(colorName)2"), forState:UIControlState.Normal)
                newButton.setBackgroundImage(UIImage(named: "\(colorName)1"), forState:UIControlState.Highlighted)
                self.addSubview(newButton)
                
            }
        
        } else if numButtsToCreate < 0 {
            let targetButtCount = slickButtons.count + numButtsToCreate
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
        for key in touchDict.keys {
            let touch = key.nonretainedObjectValue as! UITouch
            let button = touchDict[key]
            button!.highlighted = false;
            self.delegate?.didDeactivateButtonWithNoteNum(button!.tag, touchIndex: touch.touchIndex)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch
        
        for index in 0...touchIndexes.count {
            if index > touchIndexes.count - 1 {
                touch.touchIndex = touchIndexes.count
                touchIndexes.append(touchIndexes.count)
                break;
            }
            
            if index != touchIndexes[index] {
                touch.touchIndex = index
                touchIndexes.insert(index, atIndex: index)
                break;
            }
        }
        
        let touchPoint = touch.locationInView(self)
        if let button = self.hitTest(touchPoint, withEvent: UIEvent()) as? SlipperyButton {
            if !button.highlighted {
                button.highlighted = true;
            }
            self.delegate?.didActivateButtonWithNoteNum(button.tag, touchIndex: touch.touchIndex)
            touchDict[NSValue(nonretainedObject: touch)] = button
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        let key = NSValue(nonretainedObject: touch)
        
        if let movedButton = touchDict[key] as SlipperyButton! {
            let touchPoint = touch.locationInView(self)
            
            if let activeButton = self.hitTest(touchPoint, withEvent: UIEvent()) as? SlipperyButton {
                // see if we slid outside of the currently selected button
                if movedButton !== activeButton {
                    // update the touch dictionary with the new active button
                    touchDict[key] = activeButton
                    // turn on the new
                    activeButton.highlighted = true
                    // update the vc so it can change the pitch
                    self.delegate?.didChangeButton(toNoteNum: activeButton.tag, touchIndex: touch.touchIndex)
                    
                    // if the button is not being pointed to by another touch
                    if !contains(touchDict.values, movedButton) {
                        // turn it off
                        movedButton.highlighted = false;
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        let key = NSValue(nonretainedObject: touch)
        if let endedButton = touchDict[key] as SlipperyButton! {
            touchDict.removeValueForKey(key)
            
            for idx in 0...touchIndexes.count {
                if touchIndexes[idx] == touch.touchIndex {
                    touchIndexes.removeAtIndex(idx)
                    break;
                }
            }
            
            self.delegate?.didDeactivateButtonWithNoteNum(endedButton.tag, touchIndex: touch.touchIndex)
            
            // if the button is not being pointed to by another touch
            if !contains(touchDict.values, endedButton) {
                // turn it off
                endedButton.highlighted = false;
            }
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        deactivateAllButtons()
    }
    
}

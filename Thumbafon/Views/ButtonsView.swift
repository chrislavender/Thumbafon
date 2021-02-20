//
// Created by Chris Lavender on 9/12/15.
// Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import UIKit
import ObjectiveC

// Declare a global var to produce a unique address as the assoc object handle
var UITouchIndexPropertyHandle: UInt8 = 0

typealias ButtonGridDefinition = (
    numRows: Int, numCols: Int, buttWidth: CGFloat, buttHeight: CGFloat
)

protocol ButtonsViewDelegate : class {
    func calculateNumberOfButtonsForButtonView(buttonView: ButtonsView) -> (ButtonGridDefinition)?
    func calculateMidiNoteNumbersFor(buttonView: ButtonsView)
    func didActivateButtonWithNoteNum(noteNum:Int)
    func didChangeButton(toNoteNum noteNum: Int)
    func didDeactivateButtonWithNoteNum(noteNum: Int)
    func killAllNotes()
}

class ButtonsView: UIView {
    
    weak var delegate: ButtonsViewDelegate?
    
    let minCompactButtonSize: CGSize = CGSize(width:120.0, height: 130.0)
    let minRegularButtonSize: CGSize = CGSize(width: 160.0, height: 180.0)
    let buttColorNames = ["red", "pink", "purple", "blue", "aqua", "green", "seafoam", "yellow"]
    
    private(set) internal var slickButtons = [SlipperyButton]()
    private var touchDict = [NSValue : SlipperyButton]()
    
    override var canBecomeFirstResponder: Bool { return true }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ButtonsView.deactivateAllButtons),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let gridDef = self.delegate?.calculateNumberOfButtonsForButtonView(buttonView: self) {
            
            if slickButtons.count != gridDef.numRows * gridDef.numCols {
                addButtons(frame: frame, grid: gridDef)
            }
            
            var x : CGFloat = 0.0
            var y : CGFloat = self.bounds.height - gridDef.buttHeight
            var colCount = 1
            
            for button in slickButtons {
                button.frame = CGRect(x:x, y:y, width:gridDef.buttWidth, height: gridDef.buttHeight);
                x += gridDef.buttWidth;
                colCount += 1
                
                if colCount > gridDef.numCols {
                    x = 0.0
                    y = button.frame.minY - gridDef.buttHeight
                    colCount = 1 // reset for next row
                }
            }
        }
        
        self.delegate?.calculateMidiNoteNumbersFor(buttonView: self)
    }
        
    override func resignFirstResponder() -> Bool {
        deactivateAllButtons()
        return true;
    }
    
    private func calculateNumberOfButtonsForViewSize(size: CGSize) -> (ButtonGridDefinition)? {
        
        if size.width == 0.0 || size.height == 0.0 {
            return nil
        }
        
        var minButtWidth : CGFloat = 0.0
        var minButtHeight : CGFloat = 0.0
        
        if self.delegate! is UIViewController {
            let currentTraits = (self.delegate! as! UIViewController).traitCollection
            
            switch currentTraits.horizontalSizeClass {
            case .compact:
                    minButtWidth = minCompactButtonSize.width
                    break;
            case .regular:
                    minButtWidth = minRegularButtonSize.width
                    break;
            case .unspecified:
                    minButtWidth = minCompactButtonSize.width
                    break;
            @unknown default:
                fatalError()
            }
            
            switch currentTraits.verticalSizeClass {
            case .compact:
                    minButtHeight = minCompactButtonSize.height
                    break;
            case .regular:
                    minButtHeight = minRegularButtonSize.height
                    break;
            case .unspecified:
                    minButtHeight = minCompactButtonSize.height
                    break;
            @unknown default:
                fatalError()
            }
        }
        
        let numCols = Int(size.width / minButtWidth)
        let numRows = Int(size.height / minButtHeight)
        let width = size.width / CGFloat(numCols)
        let height = size.height / CGFloat(numRows)
        
        return (numRows, numCols, width, height)
    }
    
    private func addButtons(frame: CGRect, grid: ButtonGridDefinition) {
        // Create slickButton array
        let numButtons = grid.numRows * grid.numCols
        let numButtsToCreate = numButtons - slickButtons.count
        
        if numButtsToCreate > 0 {
            // we need to add some buttons
            for buttonNum in 0...numButtsToCreate - 1 {
                let colorIndex = (buttonNum) % buttColorNames.count
                let colorName = buttColorNames[colorIndex]
                
                let newButton = SlipperyButton(type: UIButton.ButtonType.custom) 
                slickButtons.append(newButton)
                newButton.setBackgroundImage(UIImage(named: "\(colorName)2"), for:UIControl.State.normal)
                newButton.setBackgroundImage(UIImage(named: "\(colorName)1"), for:UIControl.State.highlighted)
                self.addSubview(newButton)
                
            }
            
        } else if numButtsToCreate < 0 {
            // subtracking buttons? Not sure this is a real use case.
            let targetButtCount = slickButtons.count + numButtsToCreate
            for buttonIndex in (0...(slickButtons.count - 1)).reversed() {
                let button = slickButtons[buttonIndex]
                button.removeFromSuperview()
                slickButtons.remove(at: buttonIndex)
                if targetButtCount == slickButtons.count {
                    break;
                }
            }
        }
        // if the number to manage is zero then do nothing.
    }
    
    @objc func deactivateAllButtons() {
        for value in touchDict.values {
            let button = value as SlipperyButton
            button.isHighlighted = false;
        }
        self.delegate?.killAllNotes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let touchPoint = touch.location(in: self)
        if let button = self.hitTest(touchPoint, with: UIEvent()) as? SlipperyButton {
            if !button.isHighlighted {
                button.isHighlighted = true;
            }

            self.delegate?.didActivateButtonWithNoteNum(noteNum: button.tag)
            touchDict[NSValue(nonretainedObject: touch)] = button
        }
//            else {
//                println("NO BUTTON FOUND FOR TOUCH!")
//            }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let touch = touches.first!
        let key = NSValue(nonretainedObject: touch)
        
        if let movedButton = touchDict[key] as SlipperyButton? {
            let touchPoint = touch.location(in: self)
            
            if let activeButton = self.hitTest(touchPoint, with: UIEvent()) as? SlipperyButton {
                // see if we slid outside of the currently selected button
                if movedButton !== activeButton {
                    // update the touch dictionary with the new active button
                    touchDict[key] = activeButton
                    // turn on the new
                    activeButton.isHighlighted = true
                    // update the vc so it can change the pitch
                    self.delegate?.didChangeButton(toNoteNum: activeButton.tag)
                    
                    // if the button is not being pointed to by another touch
                    if !touchDict.values.contains(movedButton) {
                        // turn it off
                        movedButton.isHighlighted = false;
                    }
                }
            }
//                else {
//                    println("NO ACTIVE BUTTON FOUND FOR TOUCH!")
//                }
            
        }
//            else {
//                println("NO MOVED BUTTON FOUND FOR TOUCH!")
//            }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch = touches.first!
//        let touchIndex = touch.touchIndex as Int
        let key = NSValue(nonretainedObject: touch)
        if let endedButton = touchDict[key] as SlipperyButton? {
//            var found = false
//
//            for idx in 0...touchIndexes.count {
//                let idxValue = touchIndexes[idx] as Int
//                if idxValue == touchIndex {
//                    touchIndexes.remove(at: idx)
//                    found = true
//                    break;
//                }
//            }
            
//                if !found {
//                    println("TOUCH NOT FOUND! touchIndex:\(touch.touchIndex) touchIndexes:\(touchIndexes) dict:\(touchDict.count)")
//                }
            touchDict.removeValue(forKey: key)
//                if touchDict.count != touchIndexes.count {
//                    println("touchDict Count: \(touchDict.count)")
//                    println("touchIndexes: \(touchIndexes)")
//                    println("WTF? touchIndex:\(touch.touchIndex) touchIndexes:\(touchIndexes) dict:\(touchDict.count)")
//                }
            
            self.delegate?.didDeactivateButtonWithNoteNum(noteNum: endedButton.tag)
            
            // if the button is not being pointed to by another touch
            if !touchDict.values.contains(endedButton) {
                // turn it off
                endedButton.isHighlighted = false;
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        deactivateAllButtons()
    }
    
}

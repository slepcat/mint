//
//  WorkspaceView.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/16.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

@objc(WorkspaceView) class WorkspaceView:NSView {
    
    @IBOutlet weak var workspace : MintWorkspaceController!
    @IBOutlet weak var controller : MintController!
    
    // set acceptable drag items
    override func awakeFromNib() {
        self.registerForDraggedTypes(["leaf", "type", "instance"])
    }
    
    // Tell valid drag operation type. need to match with op. type of drag source.
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.Generic: // from toolbar
            return NSDragOperation.Generic
        case NSDragOperation.Copy: //from inside workspace
            return NSDragOperation.Copy
        case NSDragOperation.Link:
            return NSDragOperation.Link
        case NSDragOperation.Move:
            return NSDragOperation.Move
        default: //anything else
            return NSDragOperation.None
        }
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        let pboad = sender.draggingPasteboard()?
        if let leaf = pboad {
            switch sender.draggingSourceOperationMask() {
            case NSDragOperation.Generic:// from toolbar
                if let toolname = leaf.stringForType("leaf") {
                    if let setname = leaf.stringForType("type") {
                        
                        let droppedAt : NSPoint = self.convertPoint(sender.draggedImageLocation(), fromView: nil)
                        let command = AddLeaf(toolName: toolname, setName: setname, pos: droppedAt)
                        
                        controller.sendCommand(command)
                        
                        println("recieved! \(toolname) in \(setname) set")
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            // will be implemented
            //case NSDragOperation.Move:
                
            //case NSDragOperation.Link:
                
            //case NSDragOperation.Copy:
                
            default: //anything else will be failed
                return false
            }
        } else {
            return false
        }
        
        return true
    }
}


// View of leaf instance
@objc(LeafView) class LeafView : NSView {
    @IBOutlet weak var controller : MintLeafViewController!
    //var leafID : Int = -1
    //weak var controller : MintController!
    
    var boundPath : NSBezierPath? = nil
    var focus : Bool = false
    var dragging : Bool = false
    var color : NSColor = NSColor()
    
    override var acceptsFirstResponder : Bool {
        get {
            return true
        }
    }
    
    override func awakeFromNib() {
        //if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
        //    controller = delegate.controller
        //}
        
        switch controller.leafType {
            case "Test":
            color = NSColor(calibratedWhite: 0.5, alpha: 1)
        default:
            color = NSColor(calibratedWhite: 0.5, alpha: 1)
        }
        
        boundPath = NSBezierPath(roundedRect: self.bounds, xRadius: 6.0, yRadius: 6.0)
        boundPath?.lineWidth = 3.0
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if let background = boundPath {
            color.set()
            
            background.fill()
            
        }
        
        if focus {
            if let focusRing = boundPath {
                let ringColor = NSColor(calibratedRed: 0.3, green: 1, blue: 0.3, alpha: 1)
                
                ringColor.setStroke()
                focusRing.stroke()
            }
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let pt : NSPoint = convertPoint(theEvent.locationInWindow, fromView: nil)
        let hit : Bool = isPointInItem(pt)
        
        if hit {
            dragging = true
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        if dragging {
            setNeedsDisplayInRect(frame)
            
            var pos : NSPoint = frame.origin
            pos.x += theEvent.deltaX
            pos.y -= theEvent.deltaY
            
            setFrameOrigin(pos)
            
            autoscroll(theEvent)
            
            setNeedsDisplayInRect(frame)
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        dragging = false
    }
    
    func isPointInItem(pos: NSPoint) -> Bool {
        if let path = boundPath {
            return path.containsPoint(pos)
        } else {
            return false
        }
    }
    
    // trigger remove by delete keydown
    override func keyDown(theEvent: NSEvent) {
        
        let keystroke = theEvent.charactersIgnoringModifiers
        
        if let key = keystroke {
            if key.utf16Count == 1 {
                let s = key.unicodeScalars
                let v = s[s.startIndex].value
                
                if Int(v) == NSDeleteCharacter {
                    controller.removeSelf()
                    return
                }
            }
        }
        
        super.keyDown(theEvent)
    }
    
    // focus ring management
    
    override func becomeFirstResponder() -> Bool {
        focus = true
        
        needsDisplay = true
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        focus = false
        
        needsDisplay = true
        
        return super.resignFirstResponder()
    }
}

class MintArgumentCellView : NSTableCellView, NSTextFieldDelegate {
    @IBOutlet weak var value: NSTextField!
    @IBOutlet weak var rmbutton: NSButton!
    
    weak var controller: MintLeafViewController!
    
    override func awakeFromNib() {
        value.delegate = self
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        println("value edited at \(self.value.stringValue)")
        
        if let label = self.textField?.stringValue {
            controller.argument(label, valueShouldEndEditing: control.stringValue)
        }
        
        return true
    }
    
}

class MintVectorCellView : MintArgumentCellView {
    @IBOutlet weak var value2: NSTextField!
    @IBOutlet weak var value3: NSTextField!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        value2.delegate = self
        value3.delegate = self
    }
    
    override func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        if var label = self.textField?.stringValue {
            
            if control === value {
                println("value edited at \(self.value.stringValue)")
                controller.argument(label + "/x", valueShouldEndEditing: control.stringValue)
            } else if control === value2 {
                controller.argument(label + "/y", valueShouldEndEditing: control.stringValue)
            } else if control === value3 {
                controller.argument(label + "/z", valueShouldEndEditing: control.stringValue)
            }
        }
        
        return true
    }
}
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
    var boundPath : NSBezierPath? = nil
    var focus : Bool = false
    var dragging : Bool = false
    var color : NSColor = NSColor()
    
    override var acceptsFirstResponder : Bool {
        get {
            return true
        }
    }
    
    convenience init(rect: NSRect, color:NSColor) {
        self.init(frame: rect)
        
        self.color = color
        boundPath = NSBezierPath(roundedRect: self.bounds, xRadius: 6.0, yRadius: 6.0)
        boundPath?.lineWidth = 3.0
    }
    
    func setArguments(args: [String], types:[String]) {
        
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
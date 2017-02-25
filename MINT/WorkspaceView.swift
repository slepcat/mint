//
//  WorkspaceView.swift
//  MINT
//
//  Created by NemuNeko on 2015/03/16.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

@objc(WorkspaceView) class WorkspaceView:NSView {
    
    @IBOutlet weak var controller : MintController!
    
    let bgcolor = NSColor(calibratedWhite: 0.95, alpha: 1.0) //NSColor(catalogName: , colorName: NSBackgroundColorAttributeName)
    
    // draw background
    
    override func draw(_ dirtyRect: NSRect) {
        bgcolor.setFill()
        NSRectFill(dirtyRect)
    }
    
    // drag & drop from leaf panel
    /// set acceptable drag items
    override func awakeFromNib() {
        self.register(forDraggedTypes: ["leaf", "type", "instance"])
        
    }
    
    /// Tell valid drag operation type. need to match with op. type of drag source.
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.generic: // from toolbar
            return NSDragOperation.generic
        /* case NSDragOperation.Copy: //from inside workspace
            return NSDragOperation.Copy
        case NSDragOperation.Link:
            return NSDragOperation.Link
        case NSDragOperation.Move:
            return NSDragOperation.Move*/
        default: //anything else
            return []
        }
    }
    
    /// accept drop & tell 'controller' to generate new leaf
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        let leaf = sender.draggingPasteboard()
        
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.generic:// from toolbar
            if let toolname = leaf.string(forType: "leaf") {
                if let setname = leaf.string(forType: "type") {
                    
                    let droppedAt : NSPoint = self.convert(sender.draggedImageLocation(), from: nil)
                    let command = AddLeaf(toolName: toolname, setName: setname, pos: droppedAt)
                    
                    controller.sendCommand(command)
                    
                    Swift.print("recieved! \(toolname) in \(setname) set")
                } else {
                    return false
                }
            } else {
                return false
            }
            // will be implemented
            
            //case NSDragOperation.Copy:
            
        default: //anything else will be failed
            return false
        }
        
        return true
    }
}


@objc(WSScrollView) class WSScrollView : NSScrollView {
    @IBOutlet weak var workspace : WorkspaceView!
    
    override func awakeFromNib() {
        hasVerticalScroller = true
        hasHorizontalScroller = true
        borderType = NSBorderType.noBorder
        autoresizingMask = [NSAutoresizingMaskOptions.viewHeightSizable, NSAutoresizingMaskOptions.viewWidthSizable]
        
        documentView = workspace
    }
}

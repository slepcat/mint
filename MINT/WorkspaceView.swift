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
    
    // drag & drop from toolbar
    /// set acceptable drag items
    override func awakeFromNib() {
        self.registerForDraggedTypes(["leaf", "type", "instance"])
    }
    
    /// Tell valid drag operation type. need to match with op. type of drag source.
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.Generic: // from toolbar
            return NSDragOperation.Generic
        /* case NSDragOperation.Copy: //from inside workspace
            return NSDragOperation.Copy
        case NSDragOperation.Link:
            return NSDragOperation.Link
        case NSDragOperation.Move:
            return NSDragOperation.Move*/
        default: //anything else
            return NSDragOperation.None
        }
    }
    
    /// accept drop & tell 'controller' to generate new leaf
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        let pboad = sender.draggingPasteboard()
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

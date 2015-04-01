//
//  MintWorkspaceControllers.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/29.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

// Controller of workspace view
// Responsible to interact user action and manage leaf views
class MintWorkspaceController:NSObject {
    @IBOutlet weak var workspace: WorkspaceView!
    
    var viewStack : [LeafView] = []
    
    // Instantiate a leaf when tool dragged to workspace from toolbar.
    // Responsible for create leaf's view and model.
    func addLeaf(toolName:String, setName:String, pos:NSPoint, leafID:Int) {
        
        // test code. require smart code to determine view appearance according with leafType
        // need argument view
        let newLeaf = LeafView(rect: NSRect(origin: pos, size: CGSize(width: 100, height: 100)), color:NSColor(calibratedRed: 0.5, green: 0.5, blue: 0.5, alpha: 1), leafID:leafID)
        
        // test
        newLeaf.setArgumentsView(["width","height","depth","position"], types: ["Double","Double","Double","Vector"])
        
        viewStack += [newLeaf]
        
        workspace.addSubview(newLeaf)
        workspace.needsDisplay = true
    }
    
    func removeLeaf(removeID: Int) {
        for var i = 0; viewStack.count > i; i++ {
            if viewStack[i].leafID == removeID {
                viewStack[i].removeFromSuperview()
                viewStack.removeAtIndex(i)
                
                break
            }
        }
    }
}

// Controller of leaf view
// Manage user actions: Arguments inputs and link.
class MintLeafViewController:NSObject, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var argsPopover:NSPopover!
    @IBOutlet weak var leafview:LeafView!
    
    weak var controller:MintController!
    var leafID : Int = -1
    
    //Arguments List
    var argLabels:[String] = []
    var argTypes:[String] = []
    
    //setup leafview after loaded from xib file
    func setup(newID: Int) {
        
        leafID = newID
        
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            controller = delegate.controller
        }
    }
    
    //Provide arguments list
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return argLabels.count
    }
    
    // Provide data for NSTableView
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var identifier : String
        
        switch argTypes[row] {
            case "Double":
            identifier = "Double"
            case "Int":
            identifier = "Int"
            case "String":
            identifier = "String"
            case "Vector":
            identifier = "Vector"
            /*
            case "Vertex":
            break
            case "Plane":
            break
            case "Polygon":
            break
            case "Mesh":
            break
            */
        default:
            identifier = "Reference"
        }
        
        let result: AnyObject? = tableView.makeViewWithIdentifier(identifier , owner: self)
        
        switch identifier {
            case "Vector":
                if let toolView = result as? MintVectorCellView {
                    toolView.textField?.stringValue = argLabels[row]
                    toolView.value?.stringValue = argTypes[row]
                    toolView.value2?.stringValue = argTypes[row]
                    toolView.value3?.stringValue = argTypes[row]
                }
        default:
            if let toolView = result as? MintArgumentCellView {
                toolView.textField?.stringValue = argLabels[row]
                toolView.value?.stringValue = argTypes[row]
            }
        }

        
        return result as? NSView
    }
    
    // Provide type of return value to NSPasteboard for dragging operation
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        pboard.clearContents()
        pboard.declareTypes(["leaf", "type"], owner: self)
        if pboard.setString(argLabels[rowIndexes.firstIndex], forType:"leaf" ) {
            
            if pboard.setString(argTypes[0], forType: "type") {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    //'Link' operations
    //when "return" button dragged, generate drag as source
    
    
    //when "arguments" button clicked, show popover
    
    
    //when dragged "return" entered in arguments button, show popover
    
    
    //when dragged "return" dropped in arguments button, generate link command for controller
    
    
    //remove link when 'remove' button clicked
    
    
}



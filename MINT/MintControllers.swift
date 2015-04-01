//
//  MintControllers.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/15.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

// Controller of Mint
// Responsible to sync 'LeafView', 'GLMesh', and 'Leaf' instances
// This mean 'MintController' manage interactions between 2 controllers and
// a model: 'workspace', 'modelView', and 'interpreter'

class MintController:NSObject {
    @IBOutlet weak var workspace: MintWorkspaceController!
    @IBOutlet weak var modelView: MintModelViewController!
    var interpreter: MintInterpreter!
    
    var undoStack : [MintCommand] = []
    var redoStack : [MintCommand] = []
    
    func sendCommand(newCommand: MintCommand) {
        newCommand.prepare(workspace, modelView: modelView, interpreter: interpreter)
        newCommand.excute()
        
        undoStack.append(newCommand)
        redoStack.removeAll(keepCapacity: false)
        
        // Maximam undo is 10
        if undoStack.count > 10 {
            undoStack.removeAtIndex(0)
        }
    }
    
    func undo() {
        if let undo = undoStack.last {
            undo.undo()
            redoStack.append(undo)
            undoStack.removeLast()
        }
    }
    
    func redo() {
        if let redo = redoStack.last {
            redo.redo()
            undoStack.append(redo)
            redoStack.removeLast()
        }
    }
    
    // testcode
    func createTestLeaf() {
        let command = AddLeaf(toolName: "Cube", setName: "3D Primitives", pos: NSPoint(x:100, y:400))
        self.sendCommand(command)
    }
    
}

// Controller of Model View (openGL 3D View)
// Responsible for providing GLMesh objects to global stack
class MintModelViewController:NSObject {
    @IBOutlet var modelview: MintModelView!
    
    var globalStack : MintGlobalStack!
    
    // add mesh to model view and register to global stack as
    // observer object
    func addMesh(leafID: Int) {
        var mesh = GLmesh(leafID: leafID)
        
        // add mesh to model view
        modelview.stack.append(mesh)
        // register mesh as observer
        globalStack.registerObserver(mesh as MintObserver)
        
        // call solve() for stack leaves and update gl meshes of model view
        globalStack.solve()
        
        modelview.needsDisplay = true
    }
    
    // remove the GLmesh from stack
    func removeMesh(leafID: Int) {
        for var i = 0 ; modelview.stack.count > i; i++ {
            if modelview.stack[i].leafID == leafID {
                //remove mesh from stack and unregister Observer
                globalStack.removeObserver(modelview.stack[i])
                modelview.stack.removeAtIndex(i)
                
                // call solve() for stack leaves and update gl meshes of model view
                globalStack.solve()
                modelview.needsDisplay = true
                break
            }
        }
    }
}

enum MintToolSet : String {
    case Prim3D = "3D Primitives"
    case Prim2D = "2D Primitives"
    case Operator = "Operator"
    case Type = "Data Type"
    case Transform = "Transfomer"
}

class MintToolbarController:NSObject {
    @IBOutlet weak var toolbar : NSToolbar!
    
    var toolSets : [MintToolListController] = []
    
    override func awakeFromNib() {
        if toolSets.count == 0 {
            toolSets += [MintToolListController(toolSet: MintToolSet.Prim3D.rawValue)]
            toolSets += [MintToolListController(toolSet: MintToolSet.Prim3D.rawValue)]
        }
    }
    
    @IBAction func buttonClicked(sender: AnyObject) {
        if let view = sender as? NSView {
            if (view.tag > 0) && (view.tag <= toolSets.count) {
                toolSets[view.tag-1].showPopover(view)
            }
        }
    }
}

// Provide Tool List [toolName:String], [toolImage:NSImage] for Popover
// Using 'toolSet: String' in 'init()', load '.toolset' text file to determine contents of
// NSPopover Interface
class MintToolListController:NSObject, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var toolList : NSTableView!
    @IBOutlet weak var popover : NSPopover!
    var xibObjects : NSArray?
    
    let toolSetName : String
    var toolNames : [String] = []
    var toolImages : [NSImage] = []
    
    init(toolSet: String) {
        toolSetName = toolSet
        super.init()
        
        // load xib file
        let myXib = NSNib(nibNamed: "MintPopoverPalleteView", bundle: nil)
        
        if myXib?.instantiateWithOwner(self, topLevelObjects: &xibObjects) == nil {
            println("Failed to load xib, popover views")
        } else {
            // set data source and delegate for NSTableView
            toolList.setDataSource(self as NSTableViewDataSource)
            toolList.setDelegate(self as NSTableViewDelegate)
            
            // set drag operation mask
            toolList.setDraggingSourceOperationMask(NSDragOperation.Generic, forLocal: true)
        }
        
        // load tool list & icons
        let appBundle = NSBundle.mainBundle()
        let toolSetPath = appBundle.pathForResource(toolSet, ofType: "toolset")
        
        // read tool list of designated tool set name from NSBundle.
        if let path = toolSetPath {
            let toolSetString = String(contentsOfFile: path, encoding:NSUTF8StringEncoding, error: nil)
            
            if let string = toolSetString {
                // Divide multi line string to lines : '[String]'
                let lines = string.componentsSeparatedByString("\n")
                
                // Check each line and add to toolNames except comment line : '#' prefix
                // If the line have tool name, load icon from NSBundle
                for line in lines {
                    if !line.hasPrefix("#") && (countElements(line) > 0) {
                        toolNames += [line]
                        
                        // load icon
                        let toolIconPath = appBundle.pathForResource(line, ofType: "tiff")
                        if let path = toolIconPath {
                            let iconImage = NSImage(contentsOfFile: path)
                            
                            if let image = iconImage {
                                toolImages += [image]
                            }
                        } else {
                            // if there is no icon image for tool name, load default icon
                            let toolIconPath = appBundle.pathForResource("Cube", ofType: "tiff")
                            if let path = toolIconPath {
                                let iconImage = NSImage(contentsOfFile: path)
                                
                                if let image = iconImage {
                                    toolImages += [image]
                                }
                            }
                        }
                        // fin load image
                        // fin load tool
                    }
                }
            }
        } else {
            println("Unvalid toolset name")
        }
    }
    
    func showPopover(view: NSView) {
        popover.showRelativeToRect(view.frame, ofView: view, preferredEdge: 1)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return toolNames.count
    }
    
    // Provide data for NSTableView
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result: AnyObject? = tableView.makeViewWithIdentifier("toolView" , owner: self)
        
        if let toolView = result as? NSTableCellView {
            toolView.textField?.stringValue = toolNames[row]
            toolView.imageView?.image = toolImages[row]
        }
        
        return result as? NSView
    }
    
    // Provide leaf type (=tool name) to NSPasteboard for dragging operation
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        pboard.clearContents()
        pboard.declareTypes(["leaf", "type"], owner: self)
        if pboard.setString(toolNames[rowIndexes.firstIndex], forType:"leaf" ) {
            
            if pboard.setString(toolSetName, forType: "type") {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
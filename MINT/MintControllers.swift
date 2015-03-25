//
//  MintControllers.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/15.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

class MintController:NSObject {
    @IBOutlet var workspace: WorkspaceView!
    @IBOutlet var modelViewController: MintModelViewController!
    var globalStack : MintGlobalStack!
    
    var mint : MintInterpreter
    
    override init() {
        mint = MintInterpreter()
        super.init()
    }
    
    func createLeaf() {
        let leafFrame = NSRect(x: 50,y: 50,width: 100,height: 100)
        var newLeafView = LeafView(frame: leafFrame)
        var newLeaf = Cube() // How to determine concreate leaf type?
        
        //create leaf models
        mint.addLeaf(newLeaf)
        globalStack.addLeaf(newLeaf)
        
        //create leaf views
        workspace.addSubview(newLeafView)
        modelViewController.addLeaf(newLeaf)
    }
}

class MintModelViewController:NSObject {
    @IBOutlet var modelview: MintModelView!
    var mint : MintInterpreter!
    
    var globalStack : MintGlobalStack
    
    override init() {
        globalStack = MintGlobalStack()
        super.init()
    }
    
    func addLeaf(leaf: Leaf) {
        var mesh = GLmesh()
        
        modelview.stack.append(mesh)
        globalStack.addLeaf(leaf)
        globalStack.registerObserver(mesh as MintObserver)
    }
    
    func drawStack() {
        globalStack.solve()
    }
    
    func testMesh() {
        println("test leaf setup")
        
        var cube = Cube()
        
        cube.width = 50.0
        cube.height = 30.0
        cube.depth = 20.0
        var mesh = GLmesh()
        
        modelview.stack.append(mesh)
        globalStack.addLeaf(cube)
        
        globalStack.registerObserver(mesh as MintObserver)
        globalStack.solve()
    }
}

class MintPalleteController:NSObject {
    @IBOutlet weak var pop3DPrimitives : NSPopover!
    @IBOutlet weak var toolbar : NSToolbar!
    @IBOutlet weak var toolList : NSTableView!
    
    let toolListController = MintToolListController(toolSet: "3D Primitives")
    var test: Bool = true
    
    @IBAction func buttonClicked(sender: AnyObject) {
        if let view = sender as? NSView {
            switch view.tag {
            case 1:// 3D Primitives button Tag
                if test {
                    toolList.setDataSource(toolListController as NSTableViewDataSource)
                    toolList.setDelegate(toolListController as NSTableViewDelegate)
                    
                    test = false
                }
                pop3DPrimitives.showRelativeToRect(view.frame, ofView: view, preferredEdge: 1)
            default:
            println("Unknown NSView Object!")
            }
        }
    }
}

// Provide Tool List [toolName:String], [toolImage:NSImage] for Popover
// Using 'toolSet: String' in 'init()', load '.toolset' text file to determine contents of
// NSPopover Interface
class MintToolListController:NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var toolNames : [String] = []
    var toolImages : [NSImage] = []
    
    init(toolSet: String) {
        super.init()
        
        // test code
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
                    if !line.hasPrefix("#") {
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
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return toolNames.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result: AnyObject? = tableView.makeViewWithIdentifier("toolView" , owner: self)
        
        if let toolView = result as? NSTableCellView {
            toolView.textField?.stringValue = toolNames[row]
            toolView.imageView?.image = toolImages[row]
        }
        
        return result as? NSView
    }
}
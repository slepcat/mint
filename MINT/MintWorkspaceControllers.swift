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
    weak var interpreter:MintInterpreter!
    var leafViewXib : NSNib!
    
    var viewStack : [MintLeafViewController] = []
    var linkviews : [LinkView] = []
    
    // Instantiate a leaf when tool dragged to workspace from toolbar.
    // Responsible for create leaf's view and model.
    func addLeaf(toolName:String, setName:String, pos:NSPoint, leafID:Int) {
        
        if leafViewXib == nil {
            leafViewXib = NSNib(nibNamed: "LeafView", bundle: nil)
            
            // debug
            if leafViewXib == nil {
                println("Failed to load 'LeafViewNib' ")
            }
        }
        
        viewStack += [MintLeafViewController(newID: leafID, pos: pos, xib: leafViewXib)]
        
        if let view = viewStack.last?.leafview {
            workspace.addSubview(view)
        }
        
        if let viewctrl = viewStack.last {
            interpreter.registerObserver(viewctrl)
        }
        
        workspace.needsDisplay = true
    }
    
    func addLinkBetween(argleafID: Int, retleafID: Int) {
        
        for link in linkviews {
            if link.argleafID == argleafID && link.retleafID == retleafID {
                // we have a linkview arleady. Increment 'linkcounter'
                link.linkcounter++
                return
            }
        }
        
        var argpt = NSPoint()
        var retpt = NSPoint()
        
        // get leaves points from 'viewStack'
        
        var is2ndhit : Bool = false
        
        for leafctrl in viewStack {
            if leafctrl.leafID == argleafID {
                
                let origin = leafctrl.leafview.frame.origin
                argpt = NSPoint(x: origin.x + 85, y: origin.y + 21)
                
                if is2ndhit {
                    break
                } else {
                    is2ndhit = true
                }
            }
            
            if leafctrl.leafID == retleafID {
                
                let origin = leafctrl.leafview.frame.origin
                retpt = NSPoint(x: origin.x, y: origin.y + 21)
                
                if is2ndhit {
                    break
                } else {
                    is2ndhit = true
                }
            }
        }
        
        let origin = NSPoint(x: min(argpt.x, retpt.x), y:min(argpt.y, retpt.y))
        let size = NSSize(width: max(argpt.x, retpt.x) - min(argpt.x, retpt.x), height: max(argpt.y, retpt.y) - min(argpt.y, retpt.y))
        
        let newlink = LinkView(frame: NSRect(origin: origin, size: size))
        
        newlink.argPoint = argpt
        newlink.retPoint = retpt
        newlink.argleafID = argleafID
        newlink.retleafID = retleafID
        newlink.linkcounter++
        
        linkviews.append(newlink)
        
        workspace.addSubview(newlink)
        
        workspace.needsDisplay = true
    }
    
    func removeLinkBetween(argleafID: Int, retleafID: Int) {
        // Remove link between designated leaf IDs.
        // Only removed if 'linkcounter' = 0
        
        for var i = 0; linkviews.count > i; i++ {
            if linkviews[i].argleafID == argleafID && linkviews[i].retleafID == retleafID {
                
                linkviews[i].linkcounter--
                
                if linkviews[i].linkcounter <= 0 {
                    linkviews[i].removeFromSuperview()
                    linkviews.removeAtIndex(i)
                }
                return
            }
        }
    }
    
    func removeLinkFrom(leafID: Int) {
        // Remove link when the leaf is deleted.
        // search links from 'linkviews' and call 'removeLinkBetween()'
        
        for var i = 0; linkviews.count > i; i++ {
            if linkviews[i].argleafID == leafID || linkviews[i].retleafID == leafID {
                
                linkviews[i].linkcounter--
                
                if linkviews[i].linkcounter <= 0 {
                    linkviews[i].removeFromSuperview()
                    linkviews.removeAtIndex(i)
                }
            }
        }
    }
    
    func setNewName(leafID: Int, newName: String) {
        for var i = 0; viewStack.count > i; i++ {
            if viewStack[i].leafID == leafID {
                viewStack[i].setUniqueName(newName)
                break
            }
        }
    }
    
    func removeLeaf(removeID: Int) {
        for var i = 0; viewStack.count > i; i++ {
            if viewStack[i].leafID == removeID {
                viewStack[i].removeView()
                
                interpreter.removeObserver(viewStack[i])
                
                viewStack.removeAtIndex(i)
                
                break
            }
        }
    }
}

// Controller of leaf view
// Manage user actions: Arguments inputs and link.
class MintLeafViewController:NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, MintLeafObserver {
    @IBOutlet weak var argsPopover:NSPopover!
    @IBOutlet weak var leafview:LeafView!
    @IBOutlet weak var argList:NSTableView!
    
    weak var controller:MintController!
    var leafID : Int = -1
    var leafType : String = "Test"
    var leafName : String = ""
    
    // Xib Top level objects detain
    var xibObjects : NSArray?
    
    //Arguments List
    var argLabels:[String] = []
    var argTypes:[String] = []
    var argValues:[Any?] = []
    
    // Type of return value
    var returnType: String = ""
    
    // management of view. commmand receivers
    /// setup leafview with xib file
    init(newID: Int, pos: NSPoint, xib: NSNib?) {
        super.init()
        
        leafID = newID
        
        if xib?.instantiateWithOwner(self, topLevelObjects: &xibObjects) == nil {
            println("Failed to load xib, leaf view")
        } else {
            // set data source and delegate for NSTableView
            argList.setDataSource(self as NSTableViewDataSource)
            argList.setDelegate(self as NSTableViewDelegate)
            
            // set drag operation mask
            argList.setDraggingSourceOperationMask(NSDragOperation.Link, forLocal: true)

        }
        
        leafview.frame.origin = pos
        
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            controller = delegate.controller
        }
    }
    
    /// remove view from workspace. called after 'removeSelf()' called.
    func removeView() {
        leafview.removeFromSuperview()
    }
    
    /// setting argument value is implemented as observer 'update' protocol
    
    
    // Show popover
    @IBAction func showArgPopover(sender: AnyObject) {
        
        if let view = sender as? NSView {
            argsPopover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: 3)
        }
    }
    
    // observer protocol implementation
    /// update as observer
    func update(argLabel: String, arg: Any?) {
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == argLabel {
                argValues[i] = arg
                break
            }
        }
    }
    
    /// init observer's arg value
    func initArgs(argLabels: [String], argTypes: [String], args: [Any?]) {
        self.argValues = args
        self.argLabels = argLabels
        self.argTypes = argTypes
    }
    
    /// init observer's name
    func setUniqueName(name: String) {
        leafName = name
        leafview.nameTag.stringValue = name
    }
    
    /// init observer's return value type
    func initReturnValueType(type: String) {
        returnType = type
    }
    
    
    // hand over 'MintCommand' from view to 'MintController'
    /// tell 'controller' to remove a Leaf
    func removeSelf() {
        let command = RemoveLeaf(removeID: leafID)
        controller.sendCommand(command)
    }
    
    /// tell 'controller' when a argument is modified
    func argument(label: String ,valueShouldEndEditing value: String) {
        
        var setArg : SetArgument
        
        // Convert argument value from string to primitives
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == label.pathComponents[0] {
                switch argTypes[i] {
                case "Double":
                    let arg = NSString(string: value).doubleValue
                    setArg = SetArgument(updateID: leafID, label: argLabels[i], arg: arg)
                    controller.sendCommand(setArg)
                case "Int":
                    let arg = Int(NSString(string: value).intValue)
                    setArg = SetArgument(updateID: leafID, label: argLabels[i], arg: arg)
                    controller.sendCommand(setArg)
                case "String":
                    setArg = SetArgument(updateID: leafID, label: argLabels[i], arg: value)
                    controller.sendCommand(setArg)
                case "Vector":
                    if let vec = argValues[i] as? Vector {
                        var result : Vector?
                        
                        let s = NSString(string: value).doubleValue

                        switch label.lastPathComponent {
                        case "x":
                            result = Vector(x: s, y: vec.y, z: vec.z)
                        case "y":
                            result = Vector(x: vec.x, y: s, z: vec.z)
                        case "z":
                            result = Vector(x: vec.x, y: vec.y, z: s)
                        default:
                            result = nil
                        }
                        
                        if let vec = result {
                            setArg = SetArgument(updateID: leafID, label: label.pathComponents[0], arg: vec)
                            controller.sendCommand(setArg)
                        }
                    }
                case "Bool":
                    break
                default:
                    break
                }
                break
            }
        }
    }
    
    /// tell 'controller' when leaf name is changed
    func nameChanged(newName: String) {
        let nameChange = SetNewName(leafID: leafID, newName: newName)
        controller.sendCommand(nameChange)
    }
    
    // Provide arguments list. NSTableView delegate & data source implementation
    /// Provide number of list
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return argLabels.count
    }
    
    /// Provide data for NSTableView
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var identifier : String
        
        switch argTypes[row] {
            case "Double", "Int", "String", "Bool", "Vector":
            identifier = argTypes[row]
        default:
            identifier = "Reference"
        }
        
        let result: AnyObject? = tableView.makeViewWithIdentifier(identifier , owner: self)
        
        if let toolView = result as? MintArgumentCellView {
            toolView.controller = self
            
            switch identifier {
            case "Vector":
                if let toolView = result as? MintVectorCellView {
                    toolView.textField?.stringValue = argLabels[row]
                    
                    let vector = argValues[row] as? Vector
                    
                    if let vec = vector {
                        toolView.value1.stringValue = "\(vec.x)"
                        toolView.value2.stringValue = "\(vec.y)"
                        toolView.value3.stringValue = "\(vec.z)"
                    }
                }
                
            case "Double", "Int":
                if let toolView = result as? MintArgumentCellView {
                    toolView.textField?.stringValue = argLabels[row]
                    
                    if let value = argValues[row] {
                        toolView.value1.stringValue = "\(value)"
                    }
                }
                
            case "String":
                if let toolView = result as? MintArgumentCellView {
                    toolView.textField?.stringValue = argLabels[row]
                    
                    if let value = argValues[row] as? String {
                        toolView.value1.stringValue = value
                    }
                }
            
            case "Bool":
                if let toolView = result as? MintArgumentCellView {
                    toolView.textField?.stringValue = argLabels[row]
                    
                    if let value = argValues[row] as? Bool {
                        
                    }
                }
                
            default:
                if let toolView = result as? MintArgumentCellView {
                    toolView.textField?.stringValue = argLabels[row]
                    
                    if let value = argValues[row] {
                        toolView.value1.stringValue = "\(value)"
                    }
                }
            }

        }
        
        return result as? NSView
    }
    
    /// Provide height of row according cell type
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        switch argTypes[row] {
        case "Vector":
            return 64.0
        default:
            return 24.0
        }
    }
    
    //'Link' operations
    
    // Dragging source for tableview
    /// Provide type of return value to NSPasteboard for dragging operation
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        pboard.clearContents()
        pboard.declareTypes(["type", "sourceLeafID", "argument"], owner: self)
        if pboard.setString("argumentLink", forType:"type" ) {
            
            if pboard.setString("\(leafID)", forType: "sourceLeafID") {
                let row = rowIndexes.firstIndex
                if row != NSNotFound {
                    if pboard.setString(argLabels[row], forType: "argument") {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // when "return" button dragged, generate drag as source
    // called by MintReturnButton
    func beginDraggingReturn() -> (leafID: Int, type: String) {
        
        
        return (leafID, "")
    }
    
    // when dragged "argument" dropped in return button, generate link command for controller
    // called by MintReturnButton
    func setLinkFrom(leafID: Int , withArg: String) {
        
        println("link argument \(withArg) from leafID: \(leafID)")
        
        let command = LinkArgument(returnID: self.leafID, argumentID: leafID, label: withArg)
        controller.sendCommand(command)
    }
    
    // when dragged "return" entered in arguments button, show popover
    // called by 'MintArgumentCellView' and it's subclasses
    func showPopoverForLink() {
        
    }
    
    // when dragged "return" dropped in arguments button, generate link command for controller
    // called by 'MintArgumentCellView' and it's subclasses
    func acceptLinkFrom(leafID: Int, withReturn: String) {
        
    }
    
    // remove link when 'remove' button clicked
    // called by 'MintArgumentCellView' and it's subclasses
    func removeLinkWith(leafID: Int, withArg: String) {
        
    }
    
}

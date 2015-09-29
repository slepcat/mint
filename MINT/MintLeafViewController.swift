//
//  MintLeafViewController.swift
//  MINT
//
//  Created by NemuNeko on 2015/04/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

// Controller of leaf view
// Manage user actions: Arguments inputs and link.
class MintLeafViewController:NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSDraggingDestination, MintLeafObserver {
    @IBOutlet weak var argsPopover:NSPopover!
    @IBOutlet weak var leafview:LeafView!
    @IBOutlet weak var argList:NSTableView!
    
    //weak var controller:MintController!
    
    var uid : UInt
    var leafType : String = "Test"
    var leafName : String = ""
    
    // Xib Top level objects detain
    var xibObjects : NSArray?
    
    //Arguments List
    var args : [(uid: UInt, param: String, value: String, isRef: Bool)] = []
    
    // management of view. commmand receivers
    /// setup leafview with xib file
    init(newID: UInt, pos: NSPoint, xib: NSNib?) {
        uid = newID
        
        super.init()
        
        if xib?.instantiateWithOwner(self, topLevelObjects: &xibObjects) == nil {
            print("Failed to load xib, leaf view")
        } else {
            // set data source and delegate for NSTableView
            argList.setDataSource(self as NSTableViewDataSource)
            argList.setDelegate(self as NSTableViewDelegate)
            
            // set drag operation mask
            argList.setDraggingSourceOperationMask(NSDragOperation.Link, forLocal: true)
            
        }
        
        leafview.frame.origin = pos
        
        /*
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            controller = delegate.controller
        }
        */
    }
    
    /// remove view from workspace. called after 'removeSelf()' called.
    func removeView() {
        leafview.removeFromSuperview()
    }
    
    /// setting argument value is implemented as observer 'update' protocol
    
    
    // Show popover
    @IBAction func showArgPopover(sender: AnyObject) {
        
        if let view = sender as? NSView {
            argsPopover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: NSRectEdge.MaxY)
        }
    }
    
    // observer protocol implementation
    /// update as observer
    func update(arg: SExpr, uid: UInt) {
        
        for var i = 0; args.count > i; i++ {
            
            if args[i].uid == uid {
                args[i].value = arg.str("", level: 0)
                return
            }
        }
    }
    
    /// init observer's arg value
    func initArgs(args: [SExpr], labels: [String]) {
        
        //:::: TODO: need to repair param input :::::
        
        for var i = 0; args.count > i; i++ {
            switch args[i] {
            case let ltrl as Literal:
                self.args.append((uid: ltrl.uid, param: labels[i], value: ltrl.str("", level: 0), isRef: false))
            default:
                self.args.append((uid: args[i].uid, param: labels[i], value: "\(args[i].uid)", isRef: true))
            }
        }
    }
    
    /// init observer's name
    func setName(name: String) {
        leafName = name
        leafview.nameTag.stringValue = name
    }
    
    ///////// Mint Command ////////////
    
    /*
    
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
    
    /// tell 'controller' when a argument is modified. case of NSColor
    func argument(label: String, color: NSColor) {
        var setArg : SetArgument
        
        // Convert argument value from string to primitives
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == label.pathComponents[0] {
                switch argTypes[i] {
                case "Color":
                    let mintcolor = Color(r: Float(color.redComponent), g: Float(color.greenComponent), b: Float(color.blueComponent), a: Float(1.0))
                    setArg = SetArgument(updateID: leafID, label: label, arg: mintcolor)
                    controller.sendCommand(setArg)
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
    
    /// when dragged "argument" dropped in return button, generate link command for controller
    /// called by MintReturnButton
    func setLinkFrom(leafID: Int , withArg: String) {
        
        print("link argument \(withArg) from leafID: \(leafID)")
        
        let command = LinkArgument(returnID: self.leafID, argumentID: leafID, label: withArg)
        controller.sendCommand(command)
    }
    
    // when dragged "return" dropped in arguments button, generate link command for controller
    // called by 'MintArgumentCellView' and it's subclasses
    func acceptLinkFrom(leafID: Int, toArg: String) {
        print("link argument \(toArg) from leafID: \(leafID)")
        
        let command = LinkArgument(returnID: leafID, argumentID: self.leafID, label: toArg)
        controller.sendCommand(command)
    }
    
    /// remove link when 'remove' button clicked
    /// called by 'MintArgumentCellView' and it's subclasses
    func removeLink(label: String) {
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == label {
                if let leaf = argValues[i] as? Leaf {
                    let removeID = leaf.leafID
                    
                    let command = RemoveLink(rmRetID: removeID, rmArgID: leafID, label: argLabels[i])
                    controller.sendCommand(command)
                }
                break
            }
        }
    }
    
    /// rehape workspace to fit leaves
    func reshapeWorkspace(newframe: CGRect) {
        let newcommand = ReshapeWorkspace(newframe: newframe)
        controller.sendCommand(newcommand)
    }
    
    
    */
    
    ///////// Interact with Table View ////////////
    
    // Provide arguments list. NSTableView delegate & data source implementation
    /// Provide number of list
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return args.count
    }
    
    /// Provide data for NSTableView
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier : String
        
        switch tableColumn!.headerCell.title {
        case "Params":
            identifier = "paramCell"
        case "Values":
            identifier = "valueCell"
        case "Ref":
            identifier = "refCell"
        default:
            identifier = ""
        }
        
        let result: AnyObject? = tableView.makeViewWithIdentifier(identifier , owner: self)
        
        switch identifier {
        case "paramCell":
            if let paramView = result as? NSTableCellView {
                paramView.textField?.stringValue = args[row].param
                paramView.textField?.editable = false
            }
        case "valueCell":
            if let valueView = result as? NSTableCellView { // replace MintArgCellView
                valueView.textField?.stringValue = args[row].value
                if args[row].isRef {
                    valueView.textField?.editable = false
                } else {
                    valueView.textField?.editable = true
                }
            }
        //case "isRef":
            /*
            if let refView = result as? NSTableCellView { //replace MintRefCellView
                if args[row].isRef {
                    // refView.rmButton.enabled = true
                } else {
                    // refView.rmButton.enabled = false
                }
            }
            */
        default:
            print("Unknown type cell err")
        }
        
        return result as? NSView
    }
    
    /*
    
    //////// 'Link' operations ////////
    
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
    
    // accept drop from return button
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        return true
    }
    
    // when "return" button dragged, generate drag as source
    // called by MintReturnButton
    func beginDraggingReturn() -> (leafID: Int, type: String) {
        
        
        return (leafID, "")
    }
    */
    
    // when dragged "return" entered in arguments button, show popover
    // called by 'MintArgumentCellView' and it's subclasses or 'MintArgumentButton'
    func isLinkReqAcceptable() -> Bool {
        return true
    }
    
    /*
    // 'LinkView' observer pattern implementation
    /// register 'Observer' for view
    func registerLinkObserverForView(obs: MintLinkObserver) {
        leafview.registerObserver(obs)
    }
    
    /// remove 'Observer' from view
    func removeLinkObserverFromView(obs: MintLinkObserver) {
        leafview.removeObserver(obs)
    }
    */
}
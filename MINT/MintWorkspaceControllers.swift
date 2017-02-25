//
//  MintWorkspaceController.swift
//  MINT
//
//  Created by NemuNeko on 2015/03/29.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa


// Controller of workspace view
// Responsible to interact user action and manage leaf views
class MintWorkspaceController:NSObject, NSFilePresenter {
    @IBOutlet weak var workspace: WorkspaceView!
    @IBOutlet weak var controller: MintController!
    weak var interpreter:MintInterpreter!
    var leafViewXib : NSNib!
    
    var viewStack : [MintLeafViewController] = []
    var linkviews : [LinkView] = []
    
    var frame : CGRect {
        get{ return workspace.frame }
        set{ workspace.frame = newValue }
    }
    
    // file management
    
    var presentedItemURL : URL? {
        get {
            return fileurl
        }
    }
    
    var presentedItemOperationQueue : OperationQueue {
        get {
            return opqueue
        }
    }
    
    var fileurl : URL? = nil
    var opqueue : OperationQueue = OperationQueue()
    var edited : Bool = false
    
    override func awakeFromNib() {
        NSFileCoordinator.addFilePresenter(self)
    }
    
    func presentedItemDidMoveToURL(newURL: URL) {
        fileurl = newURL
    }
    
    // Instantiate a leaf when tool dragged to workspace from toolbar.
    // Responsible for create leaf's view and model.
    func addLeaf(_ toolName:String, setName:String, pos:NSPoint, uid:UInt) -> MintLeafViewController {
        
        if leafViewXib == nil {
            leafViewXib = NSNib(nibNamed: "LeafView", bundle: nil)
            
            // debug
            if leafViewXib == nil {
                print("Failed to load 'LeafViewNib' ")
            }
        }
        
        viewStack += [MintLeafViewController(newID: uid, pos: pos, xib: leafViewXib)]
        
        if let view = viewStack.last?.leafview {
            workspace.addSubview(view)
        }
        
        if let viewctrl = viewStack.last {
            interpreter.registerObserver(viewctrl)
            viewctrl.controller = controller
        }
        
        workspace.needsDisplay = true
        
        return viewStack.last!
    }
    
    func reshapeFrame(_ newframe: CGRect) {
        //let newrect = workspace.convertRect(newframe, toView: workspace)
        
        workspace.frame = mintUnionRect(workspace.frame, leaf:newframe)
        
        //print(workspace.frame)
    }
    
    func addLinkBetween(_ argleafID: UInt, retleafID: UInt, isRef: Bool) {
        
        for link in linkviews {
            if link.argleafID == argleafID && link.retleafID == retleafID {
                // we have a linkview arleady. Increment 'linkcounter'
                link.linkcounter += 1
                return
            }
        }
        
        var argpt = NSPoint(x: 0, y: 0)
        var retpt = NSPoint(x: 0, y: 0)
        var argLeaf : MintLeafViewController?
        var retLeaf : MintLeafViewController?
        
        // get leaves points from 'viewStack'
        
        var is2ndhit : Bool = false
        
        for leafctrl in viewStack {
            if leafctrl.uid == argleafID {
                
                argLeaf = leafctrl
                
                let origin = leafctrl.leafview.frame.origin
                argpt = NSPoint(x: origin.x + 95, y: origin.y + 42)
                
                if is2ndhit {
                    break
                } else {
                    is2ndhit = true
                }
            }
            
            if leafctrl.uid == retleafID {
                
                retLeaf = leafctrl
                
                let origin = leafctrl.leafview.frame.origin
                retpt = NSPoint(x: origin.x, y: origin.y + 42)
                
                if is2ndhit {
                    break
                } else {
                    is2ndhit = true
                }
            }
        }
        
        let origin = NSPoint(x: min(argpt.x, retpt.x) - 1.5, y:min(argpt.y, retpt.y) - 1.5)
        let size = NSSize(width: max(argpt.x, retpt.x) - min(argpt.x, retpt.x) + 3, height: max(argpt.y, retpt.y) - min(argpt.y, retpt.y) + 3)  // -1.5 & + 3　are margin for link view
        
        let newlink = LinkView(frame: NSRect(origin: origin, size: size))
        
        newlink.argPoint = argpt
        newlink.retPoint = retpt
        newlink.argleafID = argleafID
        newlink.retleafID = retleafID
        newlink.linkcounter += 1
        
        if isRef {
            newlink.setRefColor()
        }
        
        linkviews.append(newlink)
        
        workspace.addSubview(newlink)
        
        //print("constraint: \(newlink.constraints.count)")
        
        if let aleaf = argLeaf, let rleaf = retLeaf {
            aleaf.registerLinkObserverForView(newlink)
            rleaf.registerLinkObserverForView(newlink)
        }
        
        workspace.needsDisplay = true
    }
    
    func removeLinkBetween(_ argleafID: UInt, retleafID: UInt) {
        // Remove link between designated leaf IDs.
        // Only removed if 'linkcounter' = 0
        
        for i in 0..<linkviews.count {
            if linkviews[i].argleafID == argleafID && linkviews[i].retleafID == retleafID {
                
                linkviews[i].linkcounter -= 1
                
                if linkviews[i].linkcounter <= 0 {
                    
                    removeLinkObserver(linkviews[i].argleafID ,link: linkviews[i])
                    removeLinkObserver(linkviews[i].retleafID ,link: linkviews[i])
                    
                    linkviews[i].removeFromSuperview()
                    linkviews.remove(at: i)
                }
                return
            }
        }
    }
    
    func removeLinkFrom(_ leafID: UInt) {
        // Remove link when the leaf is deleted.
        // search links from 'linkviews' and remove the link
        
        var i = 0
        
        while i < linkviews.count {
            if linkviews[i].argleafID == leafID || linkviews[i].retleafID == leafID {
                if linkviews[i].argleafID == leafID {
                    removeLinkObserver(linkviews[i].argleafID ,link: linkviews[i])
                } else {
                    removeLinkObserver(linkviews[i].retleafID ,link: linkviews[i])
                }
                
                linkviews[i].removeFromSuperview()
                linkviews.remove(at: i)
                
                i -= 1 // decrement counter because length of array is modified by 'removeAtIndex()'
            }
            
            i += 1
        }
    }
    
    func removeLinkObserver(_ leafID: UInt, link: LinkView) {
        for view in viewStack {
            if view.uid == leafID {
                // view.removeLinkObserverFromView(link)
                break
            }
        }
    }
    
    func return_value(_ output: String, uid: UInt) {
        for leaf in viewStack {
            if leaf.uid == uid {
                leaf.output.stringValue = output
                break
            }
        }
    }
    
    func setNewName(_ leafID: UInt, newName: String) {
        for i in 0..<viewStack.count {
            if viewStack[i].uid == leafID {
                viewStack[i].setName(newName)
                break
            }
        }
    }
    
    func removeLeaf(_
        removeID: UInt) -> MintLeafViewController? {
        for i in 0..<viewStack.count {
            if viewStack[i].uid == removeID {
                viewStack[i].removeView()
                
                removeLinkFrom(removeID)
                
                //interpreter.removeObserver(viewStack[i])
                
                return viewStack.remove(at: i)
            }
        }
        
        return nil
    }
    
    
    ///// workspace save and load /////
    
    @IBAction func save(_ sender: AnyObject?) {
        
        let command = SaveWorkspace(leafpositions: positions())
        controller.sendCommand(command)
    }
    
    @IBAction func load(_ sender: AnyObject?) {
        
        let command = LoadWorkspace()
        controller.sendCommand(command)
        
    }
    
    @IBAction func newworkspace(_ sender: AnyObject?) {
        
        let command = NewWorkspace()
        controller.sendCommand(command)
    }
    
    func positions() -> [(uid: UInt, pos: NSPoint)] {
        var acc : [(uid: UInt, pos: NSPoint)] = []
        
        for leaf in viewStack {
            acc.append((uid: leaf.uid, pos: leaf.leafview!.frame.origin))
        }
        return acc
    }
    
    func reset_leaves() {
        
        if let port = MintStdPort.get.errport as? MintSubject {
            
            for ctrl in viewStack {
                removeLeaf(ctrl.uid)
                removeLinkFrom(ctrl.uid)
                port.removeObserver(ctrl)
            }
        }

    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        
        let command = AppQuit()
        controller.sendCommand(command)
        
        if command.willQuit {
            NSApp.terminate(self)
            return true
        } else {
            return false
        }
    }
    
}


func mintUnionRect(_ workspace: NSRect, leaf: NSRect) -> NSRect {
    
    var unionRect: NSRect = workspace
    
    let h_w = workspace.origin.y + workspace.size.height
    let w_w = workspace.origin.x + workspace.size.width
    let h_l = leaf.origin.y + leaf.size.height + workspace.origin.y
    let w_l = leaf.origin.x + leaf.size.width + workspace.origin.x
    
    if h_l > h_w {
        unionRect.size.height = h_l - workspace.origin.y
    }
    
    if w_l > w_w {
        unionRect.size.width = w_l - workspace.origin.x
    }
    
    return unionRect
}

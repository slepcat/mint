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
class MintWorkspaceController:NSObject {
    @IBOutlet weak var workspace: WorkspaceView!
    weak var interpreter:MintInterpreter!
    var leafViewXib : NSNib!
    
    var viewStack : [MintLeafViewController] = []
    var linkviews : [LinkView] = []
    
    // Instantiate a leaf when tool dragged to workspace from toolbar.
    // Responsible for create leaf's view and model.
    func addLeaf(toolName:String, setName:String, pos:NSPoint, uid:UInt) {
        
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
        }
        
        workspace.needsDisplay = true
    }
    
    func reshapeFrame(newframe: CGRect) {
        //let newrect = workspace.convertRect(newframe, toView: workspace.superview)
        let newframerect = CGRectUnion(newframe, workspace.frame)
        
        workspace.frame = newframerect
    }
    
    func addLinkBetween(argleafID: UInt, retleafID: UInt) {
        
        for link in linkviews {
            if link.argleafID == argleafID && link.retleafID == retleafID {
                // we have a linkview arleady. Increment 'linkcounter'
                link.linkcounter++
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
                argpt = NSPoint(x: origin.x + 84, y: origin.y + 19)
                
                if is2ndhit {
                    break
                } else {
                    is2ndhit = true
                }
            }
            
            if leafctrl.uid == retleafID {
                
                retLeaf = leafctrl
                
                let origin = leafctrl.leafview.frame.origin
                retpt = NSPoint(x: origin.x, y: origin.y + 19)
                
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
        newlink.linkcounter++
        
        linkviews.append(newlink)
        
        workspace.addSubview(newlink)
        
        //print("constraint: \(newlink.constraints.count)")
        
        /*
        if let aleaf = argLeaf, let rleaf = retLeaf {
            aleaf.registerLinkObserverForView(newlink)
            rleaf.registerLinkObserverForView(newlink)
        }
        */
        
        workspace.needsDisplay = true
    }
    
    func removeLinkBetween(argleafID: UInt, retleafID: UInt) {
        // Remove link between designated leaf IDs.
        // Only removed if 'linkcounter' = 0
        
        for var i = 0; linkviews.count > i; i++ {
            if linkviews[i].argleafID == argleafID && linkviews[i].retleafID == retleafID {
                
                linkviews[i].linkcounter--
                
                if linkviews[i].linkcounter <= 0 {
                    
                    removeLinkObserver(linkviews[i].argleafID ,link: linkviews[i])
                    removeLinkObserver(linkviews[i].retleafID ,link: linkviews[i])
                    
                    linkviews[i].removeFromSuperview()
                    linkviews.removeAtIndex(i)
                }
                return
            }
        }
    }
    
    func removeLinkFrom(leafID: UInt) {
        // Remove link when the leaf is deleted.
        // search links from 'linkviews' and remove the link
        
        for var i = 0; linkviews.count > i; i++ {
            if linkviews[i].argleafID == leafID || linkviews[i].retleafID == leafID {
                if linkviews[i].argleafID == leafID {
                    removeLinkObserver(linkviews[i].argleafID ,link: linkviews[i])
                } else {
                    removeLinkObserver(linkviews[i].retleafID ,link: linkviews[i])
                }
                
                linkviews[i].removeFromSuperview()
                linkviews.removeAtIndex(i)
                
                i-- // decrement counter because length of array is modified by 'removeAtIndex()'
            }
        }
    }
    
    func removeLinkObserver(leafID: UInt, link: LinkView) {
        for view in viewStack {
            if view.uid == leafID {
                // view.removeLinkObserverFromView(link)
                break
            }
        }
    }
    
    func setNewName(leafID: UInt, newName: String) {
        for var i = 0; viewStack.count > i; i++ {
            if viewStack[i].uid == leafID {
                viewStack[i].setName(newName)
                break
            }
        }
    }
    
    func removeLeaf(removeID: UInt) {
        for var i = 0; viewStack.count > i; i++ {
            if viewStack[i].uid == removeID {
                viewStack[i].removeView()
                
                removeLinkFrom(removeID)
                
                //interpreter.removeObserver(viewStack[i])
                
                viewStack.removeAtIndex(i)
                
                break
            }
        }
    }
}

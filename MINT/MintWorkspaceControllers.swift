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
    
    func reshapeFrame(newframe: CGRect) {
        //let newrect = workspace.convertRect(newframe, toView: workspace.superview)
        let newframerect = CGRectUnion(newframe, workspace.frame)
        
        workspace.frame = newframerect
    }
    
    func addLinkBetween(argleafID: Int, retleafID: Int) {
        
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
            if leafctrl.leafID == argleafID {
                
                argLeaf = leafctrl
                
                let origin = leafctrl.leafview.frame.origin
                argpt = NSPoint(x: origin.x + 84, y: origin.y + 19)
                
                if is2ndhit {
                    break
                } else {
                    is2ndhit = true
                }
            }
            
            if leafctrl.leafID == retleafID {
                
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
        
        //println("constraint: \(newlink.constraints.count)")
        
        if let aleaf = argLeaf, let rleaf = retLeaf {
            aleaf.registerLinkObserverForView(newlink)
            rleaf.registerLinkObserverForView(newlink)
        }
        
        workspace.needsDisplay = true
    }
    
    func removeLinkBetween(argleafID: Int, retleafID: Int) {
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
    
    func removeLinkFrom(leafID: Int) {
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
    
    func removeLinkObserver(leafID: Int, link: LinkView) {
        for view in viewStack {
            if view.leafID == leafID {
                view.removeLinkObserverFromView(link)
                break
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
                
                removeLinkFrom(removeID)
                
                interpreter.removeObserver(viewStack[i])
                
                viewStack.removeAtIndex(i)
                
                break
            }
        }
    }
}
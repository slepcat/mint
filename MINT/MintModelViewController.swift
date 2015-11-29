//
//  MintModelViewController.swift
//  mint
//
//  Created by NemuNeko on 2015/09/29.
//  Copyright © 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

// Controller of Model View (openGL 3D View)
// Responsible for providing GLMesh objects to global stack
class MintModelViewController:NSWindowController {
    @IBOutlet weak var modelview: MintModelView!
    weak var port : Mint3DPort!
    
    func addMesh(uid: UInt) -> GLmesh {
        let newmesh = GLmesh(leafID: uid)
        modelview.stack.append(newmesh)
        return newmesh
    }
    
    func removeMesh(uid: UInt) -> GLmesh? {
        for var i = 0; modelview.stack.count > i; i++ {
            if modelview.stack[i].leafID == uid {
                return modelview.stack.removeAtIndex(i)
            }
        }
        
        return nil
    }
    
    func resetMesh() {
        modelview.stack = []
    }
    
    // update mesh & redraw
    func setNeedDisplay() {
        modelview.needsDisplay = true
    }
}




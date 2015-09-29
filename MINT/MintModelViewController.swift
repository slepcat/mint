//
//  MintModelViewController.swift
//  mint
//
//  Created by NemuNeko on 2015/09/29.
//  Copyright © 2015年 Taizo A. All rights reserved.
//
/*
import Foundation

// Controller of Model View (openGL 3D View)
// Responsible for providing GLMesh objects to global stack
class MintModelViewController:NSObject {
    @IBOutlet var modelview: MintModelView!
    
    var port : MintStdOutput
    
    // add mesh to model view and register to global stack as
    // observer object
    func addMesh(leafID: Int) {
        
        if globalStack.hasLeaf(leafID) {
            
            let mesh = GLmesh(leafID: leafID)
            
            // add mesh to model view
            modelview.stack.append(mesh)
            // register mesh as observer
            globalStack.registerObserver(mesh as MintObserver)
            
            // call solve() for stack leaves and update gl meshes of model view
            globalStack.solve()
            
            modelview.needsDisplay = true
        }
    }
    
    // remove the GLmesh from stack
    func removeMesh(leafID: Int) {
        if globalStack.hasLeaf(leafID) {
            
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
    
    // update mesh & redraw
    func setNeedDisplay() {
        globalStack.solve()
        modelview.needsDisplay = true
    }
}
*/



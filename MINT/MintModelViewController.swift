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
class MintModelViewController:NSWindowController, NSWindowDelegate {
    @IBOutlet weak var modelview: MintModelView!
    @IBOutlet weak var toggleMenu : NSMenuItem!

    //weak var port : Mint3DPort!
    
    func addMesh(_ uid: UInt) -> GLmesh {
        let newmesh = GLmesh(leafID: uid, vattrib: modelview.gl_vertex, nattrib: modelview.gl_normal, cattrib: modelview.gl_color, aattrib: modelview.gl_alpha)
        modelview.stack.append(newmesh)
        return newmesh
    }
    
    func removeMesh(_ uid: UInt) -> GLmesh? {
        for i in 0..<modelview.stack.count {
            if modelview.stack[i].leafID == uid {
                let rmd = modelview.stack.remove(at: i)
                
                if let mesh = rmd as? GLmesh {
                    return mesh
                }
            }
        }
        
        return nil
    }
    
    func addLines(_ uid: UInt) -> GLlines {
        let newlines = GLlines(leafID: uid, vattrib: modelview.gl_vertex, nattrib: modelview.gl_normal, cattrib: modelview.gl_color, aattrib: modelview.gl_alpha)
        modelview.stack.append(newlines)
        return newlines
    }
    
    func removeLines(_ uid: UInt) -> GLlines? {
        for i in 0..<modelview.stack.count {
            if modelview.stack[i].leafID == uid {
                let rmd = modelview.stack.remove(at: i)
                
                if let lines = rmd as? GLlines {
                    return lines
                }
            }
        }
        
        return nil
    }
    
    func resetMeshAndLines() {
        modelview.stack = []
    }
    
    @IBAction func togglePanel(_ sender: AnyObject?) {
        if let panel = window {
            
            if panel.isVisible {
                close()
                toggleMenu.title = "Show View Panel"
                
            } else {
                showWindow(sender)
                toggleMenu.title = "Hide View Panel"
            }
        }
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        
        toggleMenu.title = "Show View Panel"
        return true
    }
    
    // update mesh & redraw
    func setNeedDisplay() {
        modelview.needsDisplay = true
    }
}




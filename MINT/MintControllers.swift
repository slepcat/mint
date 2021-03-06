//
//  MintControllers.swift
//  MINT
//
//  Created by NemuNeko on 2015/03/15.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa


// Controller of Mint
// Responsible to sync 'LeafView', 'GLMesh', and mint-lisp interperter
// This mean 'MintController' manage interactions between 2 controllers and
// a model: 'workspace', 'modelView', and 'interpreter'

class MintController:NSObject {
    @IBOutlet weak var workspace: MintWorkspaceController!
    @IBOutlet weak var modelView: MintModelViewController!
    var interpreter: MintInterpreter!
    
    var undoStack : [MintCommand] = []
    var redoStack : [MintCommand] = []
        
    func sendCommand(_ newCommand: MintCommand) {
                
        newCommand.prepare(workspace, modelView: modelView, interpreter: interpreter)
        newCommand.execute()
        
        // todo: manage err msg
        
        undoStack.append(newCommand)
        redoStack.removeAll(keepingCapacity: false)
        
        // Maximam undo is 10
        if undoStack.count > 0 {
            undoStack.remove(at: 0)
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
}

extension MintController {
    func mark_edited() {
        workspace.edited = true
    }
    
    func reshape_workspace(_ newframe: NSRect) {
        workspace.reshapeFrame(newframe)
    }
    
    func setNeedsDisplay() {
        modelView.setNeedDisplay()
    }
    
    func run_all() {
        interpreter.run_all()
    }
    
    func cancell() {
        interpreter.cancell()
    }
    
    @IBAction func redraw(_ sender: AnyObject?) {
        run_all()
    }
    
    @IBAction func stop(_ sender: AnyObject?) {
        cancell()
    }
    
    @IBAction func toggleAutoupdate(_ sender: AnyObject?) {
        if let menuitem = sender as? NSMenuItem {
            if interpreter.autoupdate {
                interpreter.autoupdate = false
                menuitem.state = NSOffState
            } else {
                interpreter.autoupdate = true
                menuitem.state = NSOnState
            }
        }
    }
}

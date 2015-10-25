//
//  MintCommands.swift
//  MINT
//
//  Created by NemuNeko on 2015/03/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa


class AddLeaf:MintCommand {
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    let leafType : String
    let category : String
    
    var pos : NSPoint
    
    init(toolName: String, setName: String, pos:NSPoint) {
        leafType = toolName + "\n"
        category = setName
        self.pos = pos
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        
        // add leaf
        if let uid = interpreter.newSExpr(leafType) {
            // add view
            workspace.addLeaf(leafType, setName: category, pos: pos, uid: uid)
            
            // add glmesh
            //modelView.addMesh(newID)
        }

    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

/*

class SetArgument:MintCommand {
    let leafID : Int
    let argLabel : String
    let newArg : Any
    
    var oldvalue : Any? = nil
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(updateID: Int, label: String, arg:Any) {
        leafID = updateID
        argLabel = label
        newArg = arg
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        // save old value for undo or exception restre operation
        oldvalue = interpreter.getArgument(leafID, argLabel: argLabel)
        
        interpreter.setArgument(leafID, label: argLabel, arg: newArg)
        
        // catch exception
        if let err = MintErr.exc.catch {
            switch err {
            case .TypeInvalid(leafName: let name, leafID: let leafID, argname: let argname, required: let correcttype, invalid: let errtype):
                print("Argument \"\(argname)\" of leaf \(name)(ID: \(leafID)) must be \"\(correcttype)\" type, not \"\(errtype)\" type.")
                if let value = oldvalue {
                    interpreter.setArgument(leafID, label: argLabel, arg: value)
                }
            default:
                MintErr.exc.raise(err)
            }
        }
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class SetNewName:MintCommand {
    let leafID : Int
    let name : String
    var oldName : String = ""
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(leafID: Int, newName: String) {
        self.leafID = leafID
        name = newName
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        oldName = interpreter.getLeafUniqueName(leafID)
        interpreter.setNewUniqueName(leafID, newName: name)
        
        if let err = MintErr.exc.catch {
            // if new name is not unique, back view name old one
            
            switch err {
            case .NameNotUnique(newName: let name, leafID: let leafid):
                print("New name: \(name)(ID: \(leafid)) is not unique")
                workspace.setNewName(leafID, newName: oldName)
            default:
                MintErr.exc.raise(err)
            }
        }
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}
*/

class LinkArgument:MintCommand {
    let returnLeafID : UInt
    let argumentID : UInt
    let argumentLeafID : UInt
    
    var oldvalue : SExpr? = nil
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(retLeafID: UInt, argID: UInt, argleafID: UInt) {
        returnLeafID = retLeafID
        argumentLeafID = argleafID
        argumentID = argID
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        // save old value for undo
        oldvalue = interpreter.lookup(argumentID).target
        
        workspace.addLinkBetween(argumentLeafID, retleafID: returnLeafID)
        
        let target = interpreter.lookup(returnLeafID)
        if !target.conscell.isNull() {
            let oldargLeafID = interpreter.lookup_leaf_of(target.conscell.uid)
            workspace.removeLinkBetween(oldargLeafID, retleafID: returnLeafID)
        }
        
        if let oldargLeaf = oldvalue as? Pair {
            workspace.removeLinkBetween(oldargLeaf.uid, retleafID: returnLeafID)
        }
        
        interpreter.link_toArg(argumentLeafID, uid: argumentID, fromUid: returnLeafID)
        
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class RemoveLink:MintCommand {
    let argleafID : UInt
    let argumentID : UInt
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(rmArgID: UInt, argID: UInt) {
        argleafID = rmArgID
        argumentID = argID
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        let argleafID = interpreter.lookup_leaf_of(argumentID)
        
        interpreter.unlink_arg(argumentID, ofleafid: argleafID)
        
        workspace.removeLinkBetween(argleafID, retleafID: argumentID)
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

/*
class RemoveLeaf:MintCommand {
    let removeID : Int
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(removeID: Int) {
        self.removeID = removeID
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        // re-generate mesh of leaves which are linked to removed leaf.
        var linkedleaves : [Int] = interpreter.getArgLeafIDs(removeID)
        
        workspace.removeLeaf(removeID)
        modelView.removeMesh(removeID)
        interpreter.removeLeaf(removeID)
        
        for leafID in linkedleaves {
            modelView.addMesh(leafID)
        }
        
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class ReshapeWorkspace:MintCommand {
    let newframe : CGRect
    var oldFrame : CGRect
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(newframe: CGRect) {
        self.newframe = newframe
        oldFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        oldFrame = workspace.workspace.frame
        workspace.reshapeFrame(newframe)
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

*/
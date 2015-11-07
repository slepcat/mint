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
            
            let res = interpreter.run_around(uid)
            workspace.return_value(res.0.str("", level: 0), uid: res.1)
            
            // add glmesh
            //modelView.addMesh(newID)
        }

    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class AddOperand:MintCommand {
    let leafid : UInt
    let newvalue : String
    var addedargid : UInt = 0
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(leafid: UInt, newvalue:String) {
        self.leafid = leafid
        self.newvalue = newvalue
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        let def = interpreter.who_define(newvalue)
        
        addedargid = interpreter.add_arg(leafid, rawstr: newvalue)
        
        if def > 0 {
            if interpreter.set_ref(addedargid, ofleafid: leafid, symbolUid: def) {
                workspace.addLinkBetween(leafid, retleafID: def, isRef: true)
            }
        }
        
        workspace.return_value("", uid: leafid)
        
        let res = interpreter.run_around(leafid)
        workspace.return_value(res.0.str("", level: 0), uid: res.1)
        
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class SetOperand:MintCommand {
    let leafid : UInt
    let argid : UInt
    let newvalue : String
    
    var oldarg : SExpr? = nil
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(argid: UInt, leafid: UInt, newvalue:String) {
        self.leafid = leafid
        self.argid = argid
        self.newvalue = newvalue
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        // save old value for undo or exception restre operation
        oldarg = interpreter.lookup(argid).target
        
        let def = interpreter.who_define(newvalue)
        
        if def > 0 {
            if interpreter.set_ref(argid, ofleafid: leafid, symbolUid: def) {
                workspace.addLinkBetween(leafid, retleafID: def, isRef: true)
            }
        } else {
            interpreter.overwrite_arg(argid, leafid: leafid, rawstr: newvalue)
        }
        
        workspace.return_value("", uid: leafid)
        
        let res = interpreter.run_around(leafid)
        workspace.return_value(res.0.str("", level: 0), uid: res.1)
        
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}


class RemoveOperand:MintCommand {
    let argid : UInt
    let leafid : UInt
    
    var oldarg : SExpr? = nil
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(argid: UInt, ofleafid: UInt) {
        self.argid = argid
        self.leafid = ofleafid
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        // save old value for undo or exception restre operation
        oldarg = interpreter.lookup(argid).target
        
        interpreter.remove_arg(argid, ofleafid: leafid)
        
        workspace.return_value("", uid: leafid)
        
        let res = interpreter.run_around(leafid)
        workspace.return_value(res.0.str("", level: 0), uid: res.1)
        
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class LinkOperand:MintCommand {
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
        
        // loop check
        
        if interpreter.lookup_treeindex_of(returnLeafID) == interpreter.lookup_treeindex_of(argumentLeafID) {
            print("🚫⚠️Cannot ref or link within a tree", terminator:"\n")
            return
        }
        
        // save old value for undo
        oldvalue = interpreter.lookup(argumentID).target
        
        workspace.addLinkBetween(argumentLeafID, retleafID: returnLeafID, isRef: false)
        
        let target = interpreter.lookup(returnLeafID)
        if !target.conscell.isNull() {
            let oldargLeafID = interpreter.lookup_leaf_of(target.conscell.uid)
            workspace.removeLinkBetween(oldargLeafID, retleafID: returnLeafID)
            
            workspace.return_value("", uid: oldargLeafID)
            
            let res = interpreter.run_around(oldargLeafID)
            workspace.return_value(res.0.str("", level: 0), uid: res.1)
        }
        
        if let oldargLeaf = oldvalue as? Pair {
            workspace.removeLinkBetween(oldargLeaf.uid, retleafID: returnLeafID)
            
            workspace.return_value("", uid: oldargLeaf.uid)
            
            let res = interpreter.run_around(oldargLeaf.uid)
            workspace.return_value(res.0.str("", level: 0), uid: res.1)
        }
        
        interpreter.link_toArg(argumentLeafID, uid: argumentID, fromUid: returnLeafID)
        
        workspace.return_value("", uid: argumentLeafID)
        
        let res = interpreter.run_around(argumentLeafID)
        workspace.return_value(res.0.str("", level: 0), uid: res.1)
        
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
        //let argleafID = interpreter.lookup_leaf_of(argumentID)
        
        interpreter.unlink_arg(argumentID, ofleafid: argleafID)
        
        workspace.return_value("", uid: argleafID)
        workspace.return_value("", uid: argumentID)
        
        let res = interpreter.run_around(argleafID)
        workspace.return_value(res.0.str("", level: 0), uid: res.1)
        
        let res2 = interpreter.run_around(argumentID)
        workspace.return_value(res2.0.str("", level: 0), uid: res2.1)
        
        workspace.removeLinkBetween(argleafID, retleafID: argumentID)
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class SetReference:MintCommand {
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
        
        // loop check deleted: it can caught by interpreter as error
        /*
        if interpreter.lookup_treeindex_of(returnLeafID) == interpreter.lookup_treeindex_of(argumentLeafID) {
            print("Cannot ref or link within a tree", terminator:"\n")
            return
        }
        */
        // save old value for undo
        oldvalue = interpreter.lookup(argumentID).target
        
        if interpreter.set_ref(argumentID, ofleafid: argumentLeafID, symbolUid: returnLeafID) {
            
            workspace.addLinkBetween(argumentLeafID, retleafID: returnLeafID, isRef: true)
            
            if let oldargLeaf = oldvalue as? Pair {
                workspace.removeLinkBetween(oldargLeaf.uid, retleafID: returnLeafID)
            }
            
            workspace.return_value("", uid: argumentLeafID)
            
            let res = interpreter.run_around(argumentLeafID)
            workspace.return_value(res.0.str("", level: 0), uid: res.1)
        }
        
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class RemoveReference:MintCommand {
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
        let res = interpreter.lookup(argumentID)
        
        if let sym = res.target as? MSymbol {
            let defLeafID = interpreter.who_define(sym.key)
            
            interpreter.remove_arg(argumentID, ofleafid: argleafID)
            
            workspace.return_value("", uid: argleafID)
            
            let res = interpreter.run_around(argleafID)
            workspace.return_value(res.0.str("", level: 0), uid: res.1)
            
            workspace.removeLinkBetween(argleafID, retleafID: defLeafID)
            modelView.setNeedDisplay()
        }

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
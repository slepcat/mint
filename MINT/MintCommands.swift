//
//  MintCommands.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/19.
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
        leafType = toolName
        category = setName
        self.pos = pos
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func excute() {
        
        let newID = LeafID.get.newID
        // add leaf
        interpreter.addLeaf(leafType, leafID: newID)
        // add view
        workspace.addLeaf(leafType, setName: category, pos: pos, leafID: newID)

        // add glmesh
        modelView.addMesh(newID)
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class SetArgument:MintCommand {
    let leafID : Int
    let argLabel : String
    let newArg : Any
    
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
    
    func excute() {
        interpreter.setArgument(leafID, label: argLabel, arg: newArg)
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
    
    func excute() {
        oldName = interpreter.getLeafUniqueName(leafID)
        if !interpreter.setNewUniqueName(leafID, newName: name) {
            // if new name is not unique, back view name old one
            workspace.setNewName(leafID, newName: oldName)
        }
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class RemoveLink:MintCommand {
    let leafID : Int
    let argLabel : String
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(rmLinkID: Int, label: String, type: String, arg:Any) {
        leafID = rmLinkID
        argLabel = label
        
        
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func excute() {
        
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

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
    
    func excute() {
        workspace.removeLeaf(removeID)
        modelView.removeMesh(removeID)
        interpreter.removeLeaf(removeID)
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}
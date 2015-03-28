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
        // add view
        workspace.addLeaf(leafType, setName: category, pos: pos)
        // add leaf
        interpreter.addLeaf(leafType)
        // add glmesh
        modelView.addMesh()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class SetArgument:MintCommand {
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
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

class RemoveArgument:MintCommand {
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
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
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
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
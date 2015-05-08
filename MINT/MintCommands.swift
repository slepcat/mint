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
    
    func execute() {
        
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
                println("Argument \"\(argname)\" of leaf \(name)(ID: \(leafID)) must be \"\(correcttype)\" type, not \"\(errtype)\" type.")
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
                println("New name: \(name)(ID: \(leafid)) is not unique")
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


class LinkArgument:MintCommand {
    let returnLeafID : Int
    let argumentLeafID : Int
    let argLabel : String
    
    var oldvalue : Any? = nil
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(returnID: Int, argumentID: Int, label: String) {
        returnLeafID = returnID
        argumentLeafID = argumentID
        argLabel = label
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        // save old value for undo or exception restre operation
        oldvalue = interpreter.getArgument(argumentLeafID, argLabel: argLabel)
        
        workspace.addLinkBetween(argumentLeafID, retleafID: returnLeafID)
        modelView.removeMesh(returnLeafID)
        interpreter.linkArgument(argumentLeafID, label: argLabel, retLeafID: returnLeafID)
        
        // catch exception
        if let err = MintErr.exc.catch {
            switch err {
            case .TypeInvalid(leafName: let name, leafID: let leafID, argname: let argname, required: let correcttype, invalid: let errtype):
                println("Argument \"\(argname)\" of leaf \(name)(ID: \(leafID)) must be \"\(correcttype)\" type, not \"\(errtype)\" type.")
                interpreter.removeLink(returnLeafID, argleafID: argumentLeafID, label: argLabel)
                if let value = oldvalue {
                    interpreter.setArgument(argumentLeafID, label: argLabel, arg: value)
                }
                workspace.removeLinkBetween(argumentLeafID, retleafID: returnLeafID)
                modelView.addMesh(returnLeafID)
            case .ReferenceLoop(leafName: let name, leafID: let leafID, argname: let argname):
                println("Loop of reference is detected at argument \"\(argname)\" of Leaf \(name)(ID: \(leafID)).")
                interpreter.removeLink(returnLeafID, argleafID: argumentLeafID, label: argLabel)
                interpreter.loopCleared()
                if let value = oldvalue {
                    interpreter.setArgument(argumentLeafID, label: argLabel, arg: value)
                }
                workspace.removeLinkBetween(argumentLeafID, retleafID: returnLeafID)
                modelView.addMesh(returnLeafID)
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

class RemoveLink:MintCommand {
    let argleafID : Int
    let retleafID : Int
    let argLabel : String
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(rmRetID: Int, rmArgID: Int, label: String) {
        argleafID = rmArgID
        retleafID = rmRetID
        argLabel = label
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        interpreter.removeLink(retleafID, argleafID: argleafID, label: argLabel)
        workspace.removeLinkBetween(argleafID, retleafID: retleafID)
        modelView.addMesh(retleafID)
        modelView.setNeedDisplay()
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
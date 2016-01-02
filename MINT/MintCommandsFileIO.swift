//
//  MintCommandsFileIO.swift
//  mint
//
//  Created by NemuNeko on 2015/12/31.
//  Copyright © 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

class SaveWorkspace:MintCommand {
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    var pos:[(uid:UInt, pos:NSPoint)]
    
    init(leafpositions: [(uid:UInt, pos:NSPoint)]) {
        pos = leafpositions
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        
        func write(url: NSURL, output: String) {
            
            let coordinator = NSFileCoordinator(filePresenter: workspace)
            let error : NSErrorPointer = NSErrorPointer()
            
            coordinator.coordinateWritingItemAtURL(url, options: .ForMerging, error: error) { (fileurl: NSURL) in
                do {
                    try output.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
                } catch {
                    print("fail to save", terminator:"\n")
                    return
                }
            }
        }
        
        let output = self.interpreter.str_with_pos(pos)
        
        if let url = workspace.presentedItemURL {
            write(url, output: output)
        } else {
            
            let panel = NSSavePanel()
            
            panel.nameFieldStringValue = "untitled.mint"
            panel.beginWithCompletionHandler(){ (result:Int) in
                if result == NSFileHandlingPanelOKButton {
                    if let url = panel.URL {
                        self.workspace.fileurl = url
                        write(url, output: output)
                        self.workspace.edited = false
                    }
                }
            }
        }
        
        /*
        if let url = workspace.fileurl {
        
        do {
        try output.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
        print("fail to save", terminator:"\n")
        return
        }
        
        } else {
        
        let panel = NSSavePanel()
        
        panel.nameFieldStringValue = "untitled.mint"
        panel.beginWithCompletionHandler(){ (result:Int) in
        if result == NSFileHandlingPanelOKButton {
        if let url = panel.URL {
        
        do {
        try output.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
        print("fail to save", terminator:"\n")
        return
        }
        
        self.workspace.fileurl = url
        }
        }
        }
        }
        */
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class LoadWorkspace:MintCommand {
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    var temptree : SExpr = MNull.errNull
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        
        func load(url: NSURL) -> String {
            
            let coordinator = NSFileCoordinator(filePresenter: workspace)
            let error : NSErrorPointer = NSErrorPointer()
            var output = ""
            
            coordinator.coordinateReadingItemAtURL(url, options: .WithoutChanges, error: error) { (fileurl: NSURL) in
                
                do {
                    output = try NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding) as String
                } catch {
                    print("fail to open", terminator:"\n")
                    return
                }
            }
            
            return output
        }
        
        
        if workspace.edited {
            
            let alert = NSAlert()
            alert.informativeText = "Do you want to save the current document?"
            alert.messageText = "Your change will be lost, if you don't save them"
            alert.alertStyle = .WarningAlertStyle
            alert.addButtonWithTitle("Save")
            alert.addButtonWithTitle("Cancel")
            alert.addButtonWithTitle("Don't Save")
            
            let ret = alert.runModal()
            
            switch ret {
            case NSAlertFirstButtonReturn:
                let command = SaveWorkspace(leafpositions: workspace.positions())
                workspace.controller.sendCommand(command)
            case NSAlertSecondButtonReturn:
                return
            default:
                break
            }
        }
        
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["mint"]
        
        panel.beginWithCompletionHandler(){ (result:Int) in
            if result == NSFileHandlingPanelOKButton {
                
                self.interpreter.trees = []
                self.interpreter.init_env()
                self.workspace.reset_leaves()
                self.modelView.resetMesh()
                self.modelView.setNeedDisplay()
                
                if let url = panel.URL {
                    
                    let input : String = load(url)
                    let localtrees = self.interpreter.readfile(input)
                    
                    for tree in localtrees {
                        
                        self.temptree = tree
                        
                        if let pair = tree as? Pair {
                            var acc : [(uid: UInt, pos: NSPoint)] = []
                            let unwrapped = self.rec_unwrap_pos(pair, pos_acc: &acc)
                            self.interpreter.trees.append(unwrapped)
                            self.rec_generate_leaf(unwrapped, parentid: 0, pos_acc: acc)
                        }
                    }
                    
                    
                    self.interpreter.init_env()
                    let symbols = self.interpreter.collect_symbols()
                    
                    for sym in symbols {
                        if let def = self.interpreter.who_define(sym) {
                            if let arg = self.interpreter.lookup_leaf_of(sym.uid) {
                                self.workspace.addLinkBetween(arg, retleafID: def, isRef: true)
                            }
                        }
                    }
                    
                    
                    self.workspace.fileurl = url
                    
                    
                    // expand frame size of workspace if need.
                    var rectacc : NSRect = self.workspace.frame
                    
                    for ctrl in self.workspace.viewStack {
                        rectacc = mintUnionRect(rectacc, leaf: ctrl.frame)
                    }
                    
                    self.workspace.frame = rectacc
                    
                }
            }
        }
    }
    
    private func rec_unwrap_pos(var head: Pair, inout pos_acc: [(uid: UInt, pos: NSPoint)]) -> Pair {
        var is_pos : Bool = false
        var pos_x : Double = 100
        var pos_y : Double = 100
        
        // check if the s-expression is wrapped by "_pos_" expression
        // if yes, unwrap and get position
        if let pos = head.car as? MSymbol {
            if pos.key == "_pos_" {
                
                is_pos = true
                
                switch head.cadr {
                case let x as MDouble:
                    pos_x = x.value
                case let x as MInt:
                    pos_x = Double(x.value)
                default:
                    if let prev = pos_acc.last, let pair = temptree as? Pair {
                        let parent_uid = interpreter.rec_lookup_leaf(head.uid, expr: pair)
                        if parent_uid == prev.uid {
                            pos_x = Double(prev.pos.x) + 130
                        }
                    }
                }
                
                switch head.caddr {
                case let y as MDouble:
                    pos_y = y.value
                case let y as MInt:
                    pos_y = Double(y.value)
                default:
                    if let prev = pos_acc.last, let pair = temptree as? Pair {
                        let parent_uid = interpreter.rec_lookup_leaf(head.uid, expr: pair)
                        if parent_uid != prev.uid {
                            pos_y = Double(prev.pos.y) + 100
                        }
                    }
                }
                
                if let leaf = head.cadddr as? Pair {
                    head = leaf
                }
            }
        }
        
        if !is_pos {
            if let prev = pos_acc.last, let pair = temptree as? Pair {
                let parent_uid = interpreter.rec_lookup_leaf(head.uid, expr: pair)
                if parent_uid == prev.uid {
                    pos_x = Double(prev.pos.x) + 130
                } else {
                    pos_y = Double(prev.pos.y) + 100
                }
            }
        }
        
        pos_acc.append((head.uid, NSPoint(x: pos_x, y: pos_y)))
        
        let opds = delayed_list_of_values(head)
        
        for var i = 0; opds.count > i; i++ {
            if let pair = opds[i] as? Pair {
                
                if let parent = temptree.lookup_exp(pair.uid).conscell as? Pair {
                    parent.car = rec_unwrap_pos(pair, pos_acc: &pos_acc)
                }
            }
        }
        
        return head
    }
    
    private func rec_generate_leaf(head: Pair, parentid: UInt, pos_acc: [(uid: UInt, pos: NSPoint)]) {
        
        // generate leaf
        
        let leaf = workspace.addLeaf("", setName: head.car.str("", level: 0), pos: get_pos(pos_acc, uid: head.uid), uid: head.uid)
        
        if let port = MintStdPort.get.errport as? MintSubject {
            port.registerObserver(leaf)
        }
        
        // add glmesh
        if head.car.str("", level: 0) == "display" {
            let mesh = modelView.addMesh(head.car.uid)
            if let port = MintStdPort.get.port as? MintSubject {
                port.registerObserver(mesh)
            }
        }
        
        // generate link
        if parentid != 0 {
            workspace.addLinkBetween(parentid, retleafID: head.uid, isRef: false)
        }
        
        let opds = delayed_list_of_values(head)
        
        for o in opds {
            if let pair = o as? Pair {
                rec_generate_leaf(pair, parentid: head.uid, pos_acc: pos_acc)
            }
        }
    }
    
    private func get_pos(positions: [(uid: UInt, pos: NSPoint)], uid: UInt) -> NSPoint {
        for pos in positions {
            if pos.uid == uid {
                return pos.pos
            }
        }
        
        return NSPoint(x: 0, y: 0)
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class NewWorkspace:MintCommand {
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    var temptree : SExpr = MNull.errNull
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        
        if workspace.edited {
            
            let alert = NSAlert()
            alert.informativeText = "Do you want to save the current document?"
            alert.messageText = "Your change will be lost, if you don't save them"
            alert.alertStyle = .WarningAlertStyle
            alert.addButtonWithTitle("Save")
            alert.addButtonWithTitle("Cancel")
            alert.addButtonWithTitle("Don't Save")
            
            let ret = alert.runModal()
            
            switch ret {
            case NSAlertFirstButtonReturn:
                let command = SaveWorkspace(leafpositions: workspace.positions())
                workspace.controller.sendCommand(command)
            case NSAlertSecondButtonReturn:
                return
            default:
                break
            }
        }
        
        // all reset current workspace
        interpreter.trees = []
        interpreter.init_env()
        workspace.reset_leaves()
        modelView.resetMesh()
        workspace.fileurl = nil
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class AppQuit:MintCommand {
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    var willQuit = false
    
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        
        if workspace.edited {
            
            let alert = NSAlert()
            alert.informativeText = "Do you want to save the current document?"
            alert.messageText = "Your change will be lost, if you don't save them"
            alert.alertStyle = .WarningAlertStyle
            alert.addButtonWithTitle("Save")
            alert.addButtonWithTitle("Cancel")
            alert.addButtonWithTitle("Don't Save")
            
            let ret = alert.runModal()
            
            switch ret {
            case NSAlertFirstButtonReturn:
                let command = SaveWorkspace(leafpositions: workspace.positions())
                workspace.controller.sendCommand(command)
            case NSAlertSecondButtonReturn:
                return
            default:
                break
            }
        }
        
        willQuit = true
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class ExportSTL : MintCommand {
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    let uid : UInt
    
    init(uid: UInt) {
        self.uid = uid
    }
    
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        
        func export(url: NSURL, output: String) {
            
            let coordinator = NSFileCoordinator(filePresenter: workspace)
            let error : NSErrorPointer = NSErrorPointer()
            
            coordinator.coordinateWritingItemAtURL(url, options: .ForMerging, error: error) { (fileurl: NSURL) in
                do {
                    try output.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
                } catch {
                    print("fail to save", terminator:"\n")
                    return
                }
            }
        }
        
        let mesh = polygons_from_exp(interpreter.eval_mainthread(uid))
        
        var stlascii = "solid csg.mint\n"
        for p in mesh {
            stlascii += p.toStlString()
        }
        stlascii += "endsolid csg.mint\n"
        
        let panel = NSSavePanel()
        
        panel.nameFieldStringValue = "untitled.stl"
        panel.beginWithCompletionHandler(){ (result:Int) in
            if result == NSFileHandlingPanelOKButton {
                if let url = panel.URL {
                    export(url, output: stlascii)
                }
            }
        }
    }
    
    func polygons_from_exp(exp: SExpr) -> [Polygon] {
        let exps = delayed_list_of_values(exp)
        var mesh : [Polygon] = []
        
        for p in exps {
            if let poly = p as? MPolygon {
                mesh.append(poly.value)
            }
        }
        
        return mesh
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

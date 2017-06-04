//
//  MintCommands.swift
//  MINT
//
//  Created by NemuNeko on 2015/03/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

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
    
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        
        // add leaf
        if let uid = interpreter.newSExpr(leafType) {
            
            // add view controller and view
            let leafctrl = workspace.addLeaf(leafType, setName: category, pos: pos, uid: uid)
            // register to standard err output port
            if let port = MintStdPort.get.errport as? MintSubject {
                port.registerObserver(leafctrl)
            }
            
            // post process for link and ref
            let leaf = interpreter.lookup(uid)
            if let context = context(ofLeaf: leaf.target) {
                if context == .Display {
                    let proc = post_process(context)
                    proc(leaf.target, leaf.conscell)
                }
            }

            
            interpreter.run_around(uid)
            
            workspace.edited = true
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
    
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        addedargid = interpreter.add_arg(leafid, rawstr: newvalue)
        interpreter.run_around(leafid)
        
        // post process
        let added = interpreter.lookup(addedargid)
        if let context = context(ofElem: added.target) {
            let post_proc = post_process(context)
            post_proc(added.target, added.conscell)
        }
        
        workspace.edited = true
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
    
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        // save old value for undo or exception restre operation
        let old = interpreter.lookup(argid)
        oldarg = old.target
        
        // pre process
        
        if let context = context(ofElem: old.target) {
            let prev_proc = pre_process(context)
            prev_proc(old.target, old.conscell)
        }
        
        let uid = interpreter.overwrite_arg(argid, leafid: leafid, rawstr: newvalue)
        interpreter.run_around(leafid)
        
        // post process
        
        let newexp = interpreter.lookup(uid)
        if let context = context(ofElem: newexp.target) {
            let post_proc = post_process(context)
            post_proc(newexp.target, newexp.conscell)
        }
        
        workspace.edited = true
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
    
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        // save old value for undo or exception restre operation
        let old = interpreter.lookup(argid)
        oldarg = old.target
        
        // pre process
        
        if let context = context(ofElem: old.target) {
            let prev_proc = pre_process(context)
            prev_proc(old.target, old.conscell)
            
            var wasGlobal = false
            
            if let sym = old.target as? MSymbol {
                wasGlobal = interpreter.isSymbol_as_global(sym)
            }
            
            interpreter.remove_arg(argid, ofleafid: leafid)
            interpreter.run_around(leafid)
            
            switch context {
            case .DeclVar, .Define:
                if wasGlobal {
                    // if changed declaration is global, reset all ref links
                    for tree in self.interpreter.trees {
                        self.rec_add_ref_links(ofleaf: tree)
                    }
                } else {
                    // if changed declaration is local, add ref links of the tree
                    if let i = self.interpreter.lookup_treeindex_of(leafid) {
                        self.rec_add_ref_links(ofleaf: self.interpreter.trees[i])
                    }
                }
            default:
                break
            }
        }
        
        
        
        workspace.edited = true
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
    
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        
        // loop check
        
        if interpreter.lookup_treeindex_of(returnLeafID) == interpreter.lookup_treeindex_of(argumentLeafID) {
            print("🚫Cannot link within a tree", terminator:"\n")
            return
        }
        
        // save old value for undo
        let old = interpreter.lookup(argumentID)
        oldvalue = old.target
        
        // pre process for overwritten operand
        if let context = context(ofElem: old.target) {
            let prev_proc = pre_process(context)
            prev_proc(old.target, old.conscell)
        }
        
        // pre process for linked (parent of the operand) leaf
        let leaf = interpreter.lookup(argumentLeafID)
        if let context = context(ofLeaf: leaf.target) {
            if context == .Define {
                let pre_proc = pre_process(context)
                pre_proc(leaf.target, leaf.conscell)
            }
        }
        
        // pre process for linking leaf
        let added = interpreter.lookup(returnLeafID)
        let prev_proc = pre_process(.Link)
        prev_proc(added.target, added.conscell)
        
        interpreter.link_toArg(argumentLeafID, uid: argumentID, fromUid: returnLeafID)
        interpreter.run_around(argumentLeafID)
        
        // update ref links to new scope
        // for leaf of return value
        let post_added = interpreter.lookup(returnLeafID)
        let post_proc = post_process(.Link)
        post_proc(post_added.target, post_added.conscell)
        
        // if removed arg is link to another leaf, update ref of the leaf to new scope
        if let context = context(ofElem: old.target) {
            if context == .Link {
                let post_proc = post_process(context)
                
                let removed = interpreter.lookup(old.target.uid)
                post_proc(removed.target, removed.conscell)
            }
        }
        
        // psot process for linked (parent of the operand) leaf
        if let context = context(ofLeaf: leaf.target) {
            if context == .Define {
                let post_proc = post_process(context)
                post_proc(leaf.target, leaf.conscell)
            }
        }
        
        workspace.edited = true
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
    var oldvalue : SExpr? = nil
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(rmArgID: UInt, argID: UInt) {
        argleafID = rmArgID
        argumentID = argID
    }
    
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        // save old value for undo
        let old = interpreter.lookup(argumentID)
        oldvalue = old.target
        
        // pre process
        let pre_argleaf = interpreter.lookup(argleafID)
        let pre_retleaf = interpreter.lookup(argumentID)
        let pre_proc = pre_process(.Link)
        
        pre_proc(pre_argleaf.target, pre_argleaf.conscell)
        pre_proc(pre_retleaf.target, pre_retleaf.conscell)
        
        interpreter.unlink_arg(argumentID, ofleafid: argleafID)
        //interpreter.run_around(argumentID)
        interpreter.run_around(argleafID)
        
        // post process
        let argleaf = interpreter.lookup(argleafID)
        let retleaf = interpreter.lookup(argumentID)
        let post_proc = post_process(.Link)
        
        post_proc(argleaf.target, argleaf.conscell)
        post_proc(retleaf.target, retleaf.conscell)

        workspace.edited = true
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
    
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        
        // save old value for undo
        let old = interpreter.lookup(argumentID)
        oldvalue = old.target
        
        // pre process
        if let context = context(ofElem: old.target) {
            if context != .DeclVar {
                let pre_proc = pre_process(context)
                pre_proc(old.target, old.conscell)
            } else {
                return
            }
        }
        
        if let newargid = interpreter.set_ref(argumentID, ofleafid: argumentLeafID, symbolUid: returnLeafID) {
            interpreter.run_around(argumentLeafID)
            
            let newarg = interpreter.lookup(newargid)
            
            let post_proc = post_process(MintLeafContext.VarRef)
            post_proc(newarg.target, newarg.conscell)
        }
        
        workspace.edited = true
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
    var oldvalue : SExpr? = nil
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(rmArgID: UInt, argID: UInt) {
        argleafID = rmArgID
        argumentID = argID
    }
    
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        let res = interpreter.lookup(argumentID)
        oldvalue = res.target
        
        if let _ = res.target as? MSymbol {
            
            let pre_proc = pre_process(.VarRef)
            pre_proc(res.target, res.conscell)
            
            interpreter.remove_arg(argumentID, ofleafid: argleafID)
            interpreter.run_around(argleafID)
            
            modelView.setNeedDisplay()
        }

    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

class RemoveLeaf:MintCommand {
    let removeID : UInt
    var oldvalue : SExpr = MNull()
    
    weak var workspace:MintWorkspaceController!
    weak var modelView: MintModelViewController!
    weak var interpreter: MintInterpreter!
    
    init(removeID: UInt) {
        self.removeID = removeID
    }
    
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter) {
        self.workspace = workspace
        self.modelView = modelView
        self.interpreter = interpreter
    }
    
    func execute() {
        let old = interpreter.lookup(removeID)
        oldvalue = old.target
        
        if let context = context(ofLeaf: old.target) {
            let pre_proc = pre_process(context)
            pre_proc(old.target, old.conscell)
            
            var leaves : [(target: SExpr, conscell: SExpr)] = []
            
            if context == .Link {
                if let cons = interpreter.lookup_leaf_of(old.conscell.uid) {
                    leaves.append(interpreter.lookup(cons))
                }
                
                let opds = delayed_list_of_values(old.target)
                for op in opds {
                    if let pair = op as? Pair {
                        leaves.append((pair, old.target))
                    }
                }
            }
            
            interpreter.remove(removeID)
            if let leaf = workspace.removeLeaf(removeID), let port = MintStdPort.get.errport as? MintSubject {
                port.removeObserver(leaf)
            }
            
            if context != .Link {
                let post_proc = post_process(context)
                post_proc(MNull(), MNull())
            } else {
                let post_proc = post_process(.Link)
                for leaf in leaves {
                    post_proc(leaf.target, leaf.conscell)
                }
            }
        }
        
        workspace.edited = true
        modelView.setNeedDisplay()
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}

//
//  MintCommandUtil.swift
//  mint
//
//  Created by NemuNeko on 2015/12/31.
//  Copyright © 2015年 Taizo A. All rights reserved.
//

import Foundation

enum MintLeafContext {
    case VarRef
    case Proc
    case Link
    case DeclVar
    case Define
    case Display
    case Other
}

protocol PreProcess : class {
    func pre_process(prev: SExpr)
}

protocol PostProcess : class {
    func post_process(post: SExpr)
}

class ProcessFactory {
    
    init(){}
    

}

extension MintCommand {
    
    //// check the context of current command ////
    
    // context: use for determine what pre/post process required
    // check the context of element of leaf. return nil if 'uid' is Leaf
    func context(ofElem elem: SExpr) -> MintLeafContext? {
        
        switch elem {
        case let sym as MSymbol:
            if interpreter.isDeclaration_of_var(sym) {
                return .DeclVar
            } else if interpreter.isSymbol_as_proc(sym){
                return .Proc
            } else if interpreter.isDefine(sym) { // to check inside macro
                return .Define
            } else if interpreter.isDisplay(sym){ // to check inside macro
                return .Display
            } else {
                return .VarRef
            }
        case let pair as Pair:
            
            if let sym = pair.car as? MSymbol {
                if interpreter.isDeclaration_of_var(sym) {
                    return .DeclVar
                }
            }
            
            return .Link
        case _ as MDefine, _ as MLambda:
            return .Define
        case _ as Display:
            return .Display
        default:
            return .Other
        }
        
    }
    
    // check the context of leaf. if uid is not Pair, return nil
    // do not pass the uid of element. it will incorrectly return .Link
    func context(ofLeaf leaf: SExpr) -> MintLeafContext? {
        
        if let pair = leaf as? Pair {
            let leafres = interpreter.lookup(pair.uid)
            if interpreter.isDefine(pair.car) {
                return .Define
            } else if interpreter.isDisplay(pair.car) {
                return .Display
            } else if !leafres.conscell.isNull() {
                return .Link
            } else {
                return .Other
            }
        }
        
        return nil
    }
    
    //// return process clousure according with context
    // pre process -> remove old link/ref. link and unregister observer
    // post process -> add new link/ref. link and register observer
    
    // return pre process for previous element / leaf
    func pre_process(_ context: MintLeafContext) -> (_ prev: SExpr, _ conscell: SExpr) -> () {
        switch context {
        case .Link:
            return {(prev: SExpr, conscell: SExpr) in
                // remove ref link because var scope may change
                self.rec_remove_ref_links(ofleaf: prev)
                
                // remove link between previous linked leaf and parent leaf
                if let parent_leafid = self.interpreter.lookup_leaf_of(conscell.uid) {
                    self.workspace.removeLinkBetween(parent_leafid, retleafID: prev.uid)
                }
            }
        case .VarRef:
            return {(prev: SExpr, conscell: SExpr) in
                // remove ref link because var ref change
                if let sym = prev as? MSymbol {
                    if let def = self.interpreter.who_define(sym), let leafid = self.interpreter.lookup_leaf_of(prev.uid) {
                        self.workspace.removeLinkBetween(leafid, retleafID: def)
                    }
                }
            }
        case .DeclVar:
            return {(prev: SExpr, conscell: SExpr) in
                // remove ref link because var scope change
                
                // if changed declaration is global, reset all ref links
                if let sym = prev as? MSymbol {
                    if self.interpreter.isSymbol_as_global(sym) {
                        for tree in self.interpreter.trees {
                            self.rec_remove_ref_links(ofleaf: tree)
                        }
                        return
                    }
                }
                
                // if changed declaration is local, reset ref links of the tree
                if let i = self.interpreter.lookup_treeindex_of(prev.uid) {
                    self.rec_remove_ref_links(ofleaf: self.interpreter.trees[i])
                }
            }
        case .Define:
            return {(prev: SExpr, conscell: SExpr) in
                // remove ref link because var scope change
                for tree in self.interpreter.trees {
                    self.rec_remove_ref_links(ofleaf: tree)
                }
            }
        case .Display, .Proc, .Other:
            return {(prev: SExpr, conscell: SExpr) in }
        }
    }
    
    /* no
    func pre_process(ofLeaf context: MintLeafContext) -> (prev: SExpr, conscell: SExpr) -> ()  {
        return {(prev: SExpr, conscell: SExpr) in }
    }
    */
    
    // return post process for changed element / leaf
    func post_process(_ context: MintLeafContext) -> (_ next: SExpr, _ conscell: SExpr) -> () {
        switch context {
        case .Link:
            return {(next: SExpr, conscell: SExpr) in
                // add ref link because var scope may change
                self.rec_add_ref_links(ofleaf: next)
                
                // add link between newly linked leaf and parent leaf
                if let parent_leafid = self.interpreter.lookup_leaf_of(conscell.uid) {
                    self.workspace.addLinkBetween(parent_leafid, retleafID: next.uid, isRef: false)
                }
            }
        case .VarRef:
            return {(prev: SExpr, conscell: SExpr) in
                // add ref link because var ref change
                if let sym = prev as? MSymbol {
                    if let def = self.interpreter.who_define(sym), let leafid = self.interpreter.lookup_leaf_of(prev.uid) {
                        self.workspace.addLinkBetween(leafid, retleafID: def, isRef: true)
                    }
                }
            }
        case .DeclVar:
            return {(next: SExpr, conscell: SExpr) in
                // add ref link because var scope change
                
                // if changed declaration is global, reset all ref links
                if let sym = next as? MSymbol {
                    if self.interpreter.isSymbol_as_global(sym) {
                        for tree in self.interpreter.trees {
                            self.rec_add_ref_links(ofleaf: tree)
                        }
                        return
                    }
                }
                
                // if changed declaration is local, add ref links of the tree
                if let i = self.interpreter.lookup_treeindex_of(next.uid) {
                    self.rec_add_ref_links(ofleaf: self.interpreter.trees[i])
                }
            }
        case .Define:
            return {(next: SExpr, conscell: SExpr) in
                // add ref link because var scope change
                for tree in self.interpreter.trees {
                    self.rec_add_ref_links(ofleaf: tree)
                }
            }
        case .Display, .Proc, .Other:
            return {(next: SExpr, conscell: SExpr) in }
        }
    }
    
    //// remove/add ref. links recursively ////
    
    func rec_remove_ref_links(ofleaf leaf: SExpr) {
        if let res = leaf as? Pair {
            rec_remove_ref(res, ofleafid: res.uid)
        }
    }
    
    private func rec_remove_ref(_ pair: Pair, ofleafid: UInt) {
        if let pair_car = pair.car as? Pair {
            rec_remove_ref(pair_car, ofleafid: pair_car.uid)
        } else if let sym = pair.car as? MSymbol {
            if let def = interpreter.who_define(sym) {
                workspace.removeLinkBetween(ofleafid, retleafID: def)
            }
        }
        
        if let pair_cdr = pair.cdr as? Pair {
            rec_remove_ref(pair_cdr, ofleafid: ofleafid)
        } else if let sym = pair.cdr as? MSymbol {
            if let def = interpreter.who_define(sym) {
                workspace.removeLinkBetween(ofleafid, retleafID: def)
            }
        }
    }
    
    func rec_add_ref_links(ofleaf leaf: SExpr) {
        if let res = leaf as? Pair {
            rec_add_ref(res, ofleafid: res.uid)
        }
    }
    
    private func rec_add_ref(_ pair: Pair, ofleafid: UInt) {
        if let pair_car = pair.car as? Pair {
            rec_add_ref(pair_car, ofleafid: pair_car.uid)
        } else if let sym = pair.car as? MSymbol {
            if let def = interpreter.who_define(sym) {
                workspace.addLinkBetween(ofleafid, retleafID: def, isRef: true)
            }
        }
        
        if let pair_cdr = pair.cdr as? Pair {
            rec_add_ref(pair_cdr, ofleafid: ofleafid)
        } else if let sym = pair.cdr as? MSymbol {
            if let def = interpreter.who_define(sym) {
                workspace.addLinkBetween(ofleafid, retleafID: def, isRef: true)
            }
        }
    }
}


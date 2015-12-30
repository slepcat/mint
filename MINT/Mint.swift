//
//  Mint.swift
//  MINT
//
//  Created by NemuNeko on 2015/03/15.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

public class MintInterpreter : Interpreter, MintLeafSubject {
    var observers:[MintLeafObserver] = []
    weak var controller : MintController!
    
    var autoupdate : Bool = true
    
    init(port: Mint3DPort, errport: MintErrPort) {
        
        MintStdPort.get.setPort(port)
        MintStdPort.get.setErrPort(errport)
                
        super.init()
    }
    
    // register observer (mint leaf view) protocol
    func registerObserver(observer: MintLeafObserver) {
        observers.append(observer)
        let obs = lookup(observer.uid)
        
        if let pair = obs.target as? Pair {
            if let f = pair.car.eval(global) as? Form {
                observer.init_opds(delayed_list_of_values(pair), labels: ["proc"] + f.params_str())
            } else if let p = pair.car.eval(global) as? Procedure {
                observer.init_opds(delayed_list_of_values(pair), labels: ["proc"] + p.params_str())
            } else {
                observer.init_opds(delayed_list_of_values(pair), labels: [])
            }
            
            observer.setName(pair.car.str("", level: 0))
        } else {
            print("unexpected error: leaf must be pair", terminator: "\n")
        }
    }
    
    // remove observer
    func removeObserver(observer: MintLeafObserver) {
        for var i = 0; observers.count > i; i++ {
            if observers[i] === observer {
                observers.removeAtIndex(i)
                break
            }
        }
    }
    
    // update observer
    func update(leafid: UInt, newopds:[SExpr], newuid: UInt, olduid: UInt) {
        for obs in observers {
            obs.update(leafid, newopds: newopds, newuid: newuid, olduid: olduid)
        }
    }
    
    // lookup uid of s-expression which include designated uid object.
    public func lookup_leaf_of(uid: UInt) -> UInt {
        for tree in trees {
            if tree.uid == uid {
                return uid
            } else {
                if let pair = tree as? Pair {
                    let res = rec_lookup_leaf(uid, expr: pair)
                    if res > 0 {
                        return res
                    }
                }
            }
        }
        return 0
    }
    
    public func rec_lookup_leaf(uid: UInt, expr: Pair) -> UInt {
        var unchecked : [Pair] = []
        let chain = gen_pairchain_of_leaf(expr)
        
        for pair in chain {
            if pair.car.uid == uid {
                
                return expr.uid
                
                /*
                if let pair2 = pair.car as? Pair {
                    return pair2.uid
                } else {
                    return expr.uid
                }
                */
            } else if pair.cdr.uid == uid {
                return expr.uid
            } else {
                if let pair2 = pair.car as? Pair {
                    unchecked.append(pair2)
                }
            }
        }
        
        while unchecked.count > 0 {
            let head = unchecked.removeLast()
            let res = rec_lookup_leaf(uid, expr: head)
            if res > 0 {
                return res
            }
        }
        
        return 0
    }
    
    private func gen_pairchain_of_leaf(exp:SExpr) -> [Pair] {
        var acc : [Pair] = []
        var head = exp
        
        while true {
            if let pair = head as? Pair {
                acc.append(pair)
                head = pair.cdr
            } else {
                return acc
            }
        }
        
    }
    
    ///// run around /////
    
    public func run_around(uid : UInt) -> (SExpr, UInt) {
        if autoupdate {
            return eval(uid)
        } else {
            return (MNull(), 0)
        }
    }
    
    ///// Manipulating S-Expression /////
    
    public func newSExpr(rawstr: String) -> UInt? {
        
        // internal function to generate s-expression from a proc
        func genSExp(proc: Form) -> Pair {
            
            let head = Pair(car: proc)
            var ct = head
            let params = proc.params_str()
            
            for p in params {
                ct.cdr = Pair(car: MStr(_value: "<" + p + ">" ))
                ct = ct.cdr as! Pair
            }
            
            return head
        }
        
        let expr = read(rawstr)
        
        // add defined proc and primitives
        if let s = expr as? MSymbol {
            
            if let proc = s.eval(global) as? Procedure {
                
                let list = genSExp(proc)
                list.car = s
                
                trees.append(list)
                
                return list.uid
            } else if let prim = s.eval(global) as? Primitive {
                
                let list = genSExp(prim)
                list.car = s
                
                trees.append(list)
                return list.uid
            }
            
        // add special forms
        } else if let f = expr as? Form {
            
            let list = genSExp(f)
            
            trees.append(list)
            return list.uid
            
        // add empty parathentes
        } else if let _ = expr as? MNull {
            let emptylist = Pair()
            trees.append(emptylist)
            return emptylist.uid
        }
        
        return nil//failed to add exp
    }
    
    public func remove(uid: UInt) -> SExpr {
        
        for var i = 0; trees.count > i; i++ {
            let res = trees[i].lookup_exp(uid)
            if !res.target.isNull() {
                
                let opds = delayed_list_of_values(res.target)
                
                if res.conscell.isNull() {
                    trees.removeAtIndex(i)
                    
                } else if let pair = res.conscell as? Pair {
                    
                    if pair.car.uid == uid {
                        pair.car = MStr(_value: "<unlinked>")
                        
                        let leafid = lookup_leaf_of(pair.uid)
                        
                        update(leafid, newopds: [pair.car], newuid: pair.car.uid, olduid: res.target.uid)
                    } else {
                        print("unexpected err, failed to remove leaf")
                    }
                    
                } else {
                    print("fail to remove. bad conscell", terminator: "\n")
                }
                
                for exp in opds {
                    if let pair = exp as? Pair {
                        trees.append(pair)
                    }
                }
                
                return res.target
            }
        }
        return MNull()
    }
    
    public func add_arg(uid: UInt, rawstr: String) -> UInt {
        let res = lookup(uid)
        if let pair = res.target as? Pair {
            var head = pair
            
            while !head.cdr.isNull() {
                if let pair2 = head.cdr as? Pair {
                    head = pair2
                }
            }
            
            head.cdr = Pair(car: read(rawstr + "\n"))
            
            update(uid, newopds: [head.cadr], newuid: head.cadr.uid, olduid: 0)
            print("arg (id: \(head.cadr.uid)) is added to leaf (id: \(uid))", terminator: "\n")
            print_exps()
            
            return head.cadr.uid
        }
        
        return 0
    }
    
    public func overwrite_arg(uid: UInt, leafid: UInt, rawstr: String) -> UInt {
        let res = lookup(uid)
        if let pair = res.conscell as? Pair {
            pair.car = read(rawstr + "\n")
            
            update(leafid, newopds: [pair.car], newuid: pair.car.uid, olduid: uid)
            print("arg (id: \(uid)) of leaf (id: \(leafid)) is overwritten by the new arg (id: \(pair.car.uid))", terminator: "\n")
            print_exps()
            
            return pair.car.uid
        }
        
        return 0
    }
    
    public func link_toArg(ofleafid:UInt, uid: UInt, fromUid: UInt) {
        let res = lookup(uid)
        let rewrite = lookup(fromUid)
        
        // if target leaf has been linked, unlink from member of tree.
        if !rewrite.conscell.isNull() {
            let oldleafid = lookup_leaf_of(fromUid)
            unlink_arg(fromUid, ofleafid: oldleafid)
        }
        
        // remove from trees of interpreter
        for var i = 0; trees.count > i; i++ {
            if trees[i].uid == fromUid {
                trees.removeAtIndex(i)
                print("leaf (id: \(fromUid)) removed from interpreter trees", terminator: "\n")
            }
        }
        
        if let pair = res.conscell as? Pair {
            
            // if old argument is Pair, append it to interpreter trees before overwrite.
            if let removed = res.target as? Pair {
                trees.append(removed)
                print("leaf (id: \(removed.uid)) added to interpreter trees", terminator: "\n")
            }
            
            pair.car = rewrite.target
        }
        
        update(ofleafid, newopds: [rewrite.target], newuid: fromUid, olduid: uid)
        
        print_exps()
    }
    
    public func unlink_arg(uid: UInt, ofleafid: UInt) {
        let res = lookup(uid)
        
        //if !res.target.isNull() {
        // move to interpreter trees
        trees.append(res.target)
        print("leaf (id: \(res.target.uid)) added to interpreter trees", terminator: "\n")
        //}
        
        // remove from current tree
        if let pair = res.conscell as? Pair {
            pair.car = MStr(_value: "<unlinked>")
            
            print("unlink old arg (id: \(uid)) in leaf (id: \(ofleafid))", terminator: "\n")
            
            update(ofleafid, newopds: [pair.car], newuid: pair.car.uid, olduid: uid)
        }
    }
    
    public func remove_arg(uid:UInt, ofleafid: UInt) {
        let removedArg = lookup(uid)
        let parent = lookup(removedArg.conscell.uid)
        
        if let parentPair = parent.conscell as? Pair, let removedPair = removedArg.conscell as? Pair {
            parentPair.cdr = removedPair.cdr
            
            update(ofleafid, newopds: [], newuid: 0, olduid: uid)
        } else {
            print("error: unexpected remove of element", terminator: "\n")
        }
    }
    
    public func set_ref(toArg:UInt, ofleafid:UInt, symbolUid: UInt) -> Bool{
        let def = lookup(symbolUid)
        
        if let pair = def.target as? Pair {
            if let symbol = pair.cadr as? MSymbol {
                overwrite_arg(toArg, leafid: ofleafid, rawstr: symbol.key)
                return true
            } else if let symbol = pair.caadr as? MSymbol {
                overwrite_arg(toArg, leafid: ofleafid, rawstr: symbol.key)
                return true
            } else {
                print("error: unexpectedly symbol not found", terminator:"\n")
            }
        } else {
            print("error: leaf is not define?", terminator: "\n")
        }
        
        return false
    }
    
    public func move_arg(uid: UInt, toNextOfUid: UInt) {
        let nextTo = lookup(toNextOfUid)
        let moveArg = lookup(uid)
        
        if let pair1 = nextTo.conscell as? Pair, let pair2 = moveArg.conscell as? Pair  {
            
            pair1.car = moveArg.target
            pair2.car = nextTo.target
            
        } else {
            print("error: move element must move inside conscell.", terminator: "\n")
        }
    }
    
    ///// output /////
    
    public func str_with_pos(var positions: [(uid: UInt, pos: NSPoint)]) -> String {
        
        var acc : String = ""
        
        for expr in trees {
            acc += expr.str_with_pos(&positions, indent: indent, level: 1) + "\n\n"
        }
        
        return acc
    }
    
    ///// read Env /////
    
    public func isSymbol(str:String) -> Bool {
        if let _ = global.hash_table.indexForKey(str) {
            return true
        } else {
            return false
        }
    }
    
    public func isSymbol_as_proc(str:String) -> Bool {
        if isSymbol(str) {
            if let _ = global.hash_table[str] as? Procedure {
                return true
            }
        }
        
        return false
    }
    
    public func who_define(key: String) -> UInt {
        
        for t in trees {
            if let pair = t as? Pair {
                if let _ = pair.car as? MDefine {
                    if let symbol = pair.cadr as? MSymbol {
                        if symbol.key == key {
                            return pair.uid
                        }
                    } else if let symbol = pair.caadr as? MSymbol {
                        if symbol.key == key {
                            return 0//pair.uid //proc is not take ref link
                        }
                    }
                }
            }
        }
        
        return 0
    }
    
    public func who_define(key: String, uid:UInt) -> UInt {
        
        if isSymbol_as_proc(key) {
            return 0
        }
        
        // search from bottom of binary tree
        // to applicable for lexical scope
        // ::: todo> macro applicable
        let i = lookup_treeindex_of(uid)
        if i >= 0 {
            let path = rec_root2leaf_path(key, uid: uid, exps: trees[i])
            
            for exp in path {
                
                if let pair = exp as? Pair {
                    switch pair.car {
                    case _ as MDefine:
                        if let param = pair.cadr as? MSymbol {
                            
                            if (param.uid != uid) && (param.key == key) {
                                return lookup_leaf_of(param.uid)
                            }
                            
                        } else if let paramPair = pair.cadr as? Pair {
                            let syms = delayed_list_of_values(paramPair.cdr)
                            
                            for sym in syms {
                                if let symbol = sym as? MSymbol {
                                    if (symbol.uid != uid) && (symbol.key == key) {
                                        return lookup_leaf_of(symbol.uid)
                                    } else if (symbol.uid == uid) && (symbol.key == key) {
                                        return 0
                                    }
                                }
                            }
                        }
                    case _ as MLambda:
                        
                        let syms = delayed_list_of_values(pair.cadr)
                        
                        for sym in syms {
                            if let symbol = sym as? MSymbol {
                                if (symbol.uid != uid) && (symbol.key == key) {
                                    return lookup_leaf_of(symbol.uid)
                                }
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        // if local define is not found, search global
        for var j = 0; trees.count > j; j++ {
            // skip already searched tree
            if i == j { continue }
            
            // check if this tree has the symbol
            let resid = rec_search_symbol(key, tree: trees[j])
            if resid > 0 {
                // search from root to bottom
                let path = rec_root2leaf_path(key, uid: resid, exps: trees[j]).reverse()
                
                for exp in path {
                    if let pair = exp as? Pair {
                        if let _  = pair.car as? MDefine {
                            
                            if let param = pair.cadr as? MSymbol {
                                
                                if (param.uid != uid) && (param.key == key) {
                                    return lookup_leaf_of(param.uid)
                                }
                                
                            }
                            
                        } else if let _ = pair.car as? MLambda {
                            break
                        }
                    }
                }
            }
        }
        
        
        return 0
    }
    
    // get chain of exps from target exp to tree root exp
    private func rec_root2leaf_path(key: String, uid:UInt, exps:SExpr) -> [SExpr] {
        if let atom = exps as? Atom {
            if atom.uid == uid {
                return [atom]
            } else {
                return []
            }
        } else {
            if let pair = exps as? Pair {
                if pair.uid == uid {
                    return [pair]
                } else {
                    var ret : [SExpr] = []
                    
                    let resl = rec_root2leaf_path(key, uid: uid, exps: pair.car)
                    if resl.count > 0 {
                        ret = resl + [pair]
                    }
                    
                    let resr = rec_root2leaf_path(key, uid: uid, exps: pair.cdr)
                    if resr.count > 0 {
                        ret = resr + [pair]
                    }
                    
                    return ret
                }
            }
        }
        
        return []
    }
    
    private func rec_search_symbol(key: String, tree: SExpr) -> UInt {
        if let atom = tree as? Atom {
            if let sym = atom as? MSymbol {
                if sym.key == key {
                    return sym.uid
                }
            }
        } else if let pair = tree as? Pair {
            return rec_search_symbol(key, tree: pair.car) + rec_search_symbol(key, tree: pair.cdr)
        }
        return 0
    }
    
    func collect_symbols() -> [MSymbol] {
        var acc :[MSymbol] = []
        
        for tree in trees {
            acc += rec_collect_symbols(tree)
        }
        
        return acc
    }
    
    private func rec_collect_symbols(tree: SExpr) -> [MSymbol] {
        if let sym = tree as? MSymbol {
            if !isSymbol_as_proc(sym.key) {
                return [sym]
            }
        } else if let pair = tree as? Pair {
            return rec_collect_symbols(pair.car) + rec_collect_symbols(pair.cdr)
        }
        
        return []
    }
    
    public func defined_exps() -> [String : [String]] {
        
        var acc : [String : [String]] = [:]
        
        for defined in global.hash_table {
            if let proc = defined.1 as? Procedure {
                if let list = acc[proc.category] {
                    acc[proc.category] = list + [defined.0]
                } else {
                    acc[proc.category] = [defined.0]
                }
            } else if let form = defined.1 as? Form {
                if let list = acc[form.category] {
                    acc[form.category] = list + [defined.0]
                } else {
                    acc[form.category] = [defined.0]
                }
            }
        }
        
        if let leaves = acc["3D Primitives"] {
            acc["3D Primitives"] = leaves + ["display"]
        } else {
            acc["3D Primitives"] = ["display"]
        }
        acc["lisp special form"] = ["define", "set!", "if", "quote", "lambda", "begin", "null"]
        
        return acc
    }

    ///// debugging /////
    
    func print_exps() {
        for tree in trees {
            //print(tree._debug_string(),terminator: "\n")
            print(tree.str("  ", level: 1),terminator: "\n")
        }
    }
}

extension SExpr {
    func str_with_pos(inout positions: [(uid: UInt, pos: NSPoint)], indent: String, level: Int) -> String {
        
        if let _ = self as? Pair {
            
            var leveledIndent : String = ""
            for var i = 0; level > i; i++ {
                leveledIndent += indent
            }
            
            let res = str_pos_list_of_exprs(self, positions: &positions, indent: indent, level: level + 1 )
            
            var acc : String = ""
            var pos : String = "("
            
            for var i = 0; positions.count > i; i++ {
                if self.uid == positions[i].uid {
                    pos += "_pos_ \(positions[i].pos.x) \(positions[i].pos.y)                "
                    positions.removeAtIndex(i)
                }
            }
            
            for s in res {
                if s[s.startIndex] == "(" {
                    if indent == "" {
                        acc += s
                    } else {
                        acc += "\n" + leveledIndent + s
                    }
                } else {
                    if acc == "" {
                        acc += s
                    } else {
                        acc += " " + s
                    }
                }
            }
            
            return pos + "(" + acc + "))"
            
        } else {
            return self.str(indent, level: level)
        }
    }
    
    private func str_pos_list_of_exprs(_opds :SExpr, inout positions: [(uid: UInt, pos: NSPoint)], indent:String, level: Int) -> [String] {
        if let atom = _opds as? Atom {
            return [atom.str(indent, level: level)]
        } else {
            return tail_str_pos_list_of_exprs(_opds, acc: [], positions: &positions, indent: indent, level: level)
        }
    }
    
    private func tail_str_pos_list_of_exprs(_opds :SExpr, var acc: [String], inout positions: [(uid: UInt, pos: NSPoint)], indent:String, level: Int) -> [String] {
        if let pair = _opds as? Pair {
            acc.append(pair.car.str_with_pos(&positions, indent: indent, level: level))
            return tail_str_pos_list_of_exprs(pair.cdr, acc: acc, positions: &positions, indent: indent, level: level)
        } else {
            return acc
        }
    }
}

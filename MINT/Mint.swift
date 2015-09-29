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
    
    // register observer (mint leaf view) protocol
    func registerObserver(observer: MintLeafObserver) {
        observers.append(observer)
        let obs = lookup(observer.uid)
        
        if let pair = obs.conscell as? Pair {
            if let f = obs.target as? Form {
                observer.initArgs(delayed_list_of_values(pair.cdr), labels: f.params_str())
            } else if let p = obs.target.eval(global) as? Procedure {
                observer.initArgs(delayed_list_of_values(pair.cdr), labels: p.params_str())
            }
        }
        observer.setName(obs.target.str("", level: 0))
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
                
                return s.uid
            } else if let prim = s.eval(global) as? Primitive {
                
                let list = genSExp(prim)
                list.car = s
                
                trees.append(list)
                return s.uid
            }
            
            // add special forms
        } else if let f = expr as? Form {
            
            trees.append(genSExp(f))
            return f.uid
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
                    if pair.cdr.isNull() {
                        let prev = trees[i].lookup_exp(pair.uid)
                        if let prev_pair = prev.conscell as? Pair {
                            prev_pair.cdr = MNull()
                        } else if prev.conscell.isNull() {
                            trees.removeAtIndex(i)
                        }
                    } else {
                        pair.car = pair.cadr
                        pair.cdr = pair.cddr
                    }
                } else {
                    print("fail to remove. bad conscell", terminator: "")
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
    
    public func overwrite(uid: UInt, rawstr: String) {
        let res = lookup(uid)
        if let pair = res.conscell as? Pair {
            pair.car = readln(rawstr)
        }
    }
    
    public func insert(uid: UInt, toNextOfUid: UInt) {
        let nextTo = lookup(toNextOfUid)
        
        if let pair = nextTo.conscell as? Pair {
            
            let subject = remove(uid)
            
            let newPair = Pair(car: subject, cdr: pair.cdr)
            pair.cdr = newPair
            
        } else {
            print("error: move element must move inside conscell.", terminator: "")
        }
    }
    
    ///// read Env /////
    
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
        
        acc["special form"] = ["define", "set!", "if", "quote", "lambda", "begin"]
        
        return acc
    }


}

/*
// Root level of Mint leaves chains. Should be 'Singleton'?
class MintInterpreter:MintLeafSubject {
    private var leafPool = [Leaf]()
    var globalStack = MintGlobalStack()
    var observers:[MintLeafObserver] = []
    
    // register observer (mint leaf view) protocol
    func registerObserver(observer: MintLeafObserver) {
        observers.append(observer)
        let args = getArguments(observer.leafID)
        let ret = getReturnType(observer.leafID)
        let name = getLeafUniqueName(observer.leafID)
        
        observer.initArgs(args.argLabels, argTypes: args.argTypes, args: args.args)
        observer.initReturnValueType(ret)
        observer.setUniqueName(name)
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
    
    // establish link between return value of leaf and argument value of another leaf
    
    func linkArgument(argLeafID: Int, label: String, retLeafID: Int) {
        
        for leaf in leafPool {
            if leaf.leafID == retLeafID {
                setArgument(argLeafID, label: label, arg: leaf)
                
                if leaf.returnType == "Mesh" {
                    globalStack.removeAtID(retLeafID)
                }
                
                return
            }
        }
        
        MintErr.exc.raise(MintEXC.LeafIDNotExist(leafID: retLeafID))
    }
    
    // set argument or link
    func setArgument(leafID:Int, label:String, arg:Any) {
        for leaf in leafPool {
            if leaf.leafID == leafID {
                
                leaf.setArg(label, value: arg)
                
                for obs in observers {
                    if obs.leafID == leafID {
                        obs.update(label, arg: arg)
                        break
                    }
                }
                
                return
            }
        }
        
        MintErr.exc.raise(MintEXC.LeafIDNotExist(leafID: leafID))
    }
    
    // init argument or link
    func initArgument(leafID:Int, label:String) {
        for leaf in leafPool {
            if leaf.leafID == leafID {
                
                leaf.initArg(label)
                
                for obs in observers {
                    if obs.leafID == leafID {
                        obs.update(label, arg: leaf.getArg(label))
                        break
                    }
                }
                
                return
            }
        }
        
        MintErr.exc.raise(MintEXC.LeafIDNotExist(leafID: leafID))
    }
    
    // get all arguments of leaf
    func getArguments(leafID: Int) -> (argLabels: [String], argTypes:[String], args: [Any?]) {
        for leaf in leafPool {
            if leaf.leafID == leafID {
                var args = leaf.getArgs()
                
                for var i = 0; args.argTypes.count > i; i++  {
                    switch args.argTypes[i] {
                        case "Int", "Double", "String", "Vector":
                        break
                    default: // Reference Type
                        args.args[i] = getLeafUniqueName(leafID) + ": \(leafID)"
                    }
                }
                return args
            }
        }
        
        MintErr.exc.raise(MintEXC.LeafIDNotExist(leafID: leafID))
        return ([], [], [])
    }
    
    // get a arguments of leaf
    func getArgument(leafID: Int, argLabel: String) -> Any? {
        for leaf in leafPool {
            if leaf.leafID == leafID {
                var arg = leaf.getArg(argLabel)
                
                return arg
            }
        }
        
        MintErr.exc.raise(MintEXC.LeafIDNotExist(leafID: leafID))
        return nil
    }
    
    func getReturnType(leafID: Int) -> String {
        for leaf in leafPool {
            if leaf.leafID == leafID {
                return leaf.returnType
            }
        }
        
        MintErr.exc.raise(MintEXC.LeafIDNotExist(leafID: leafID))
        return ""
    }
    
    // remove link
    // called when argument link deleted
    func removeLink(retleafID: Int, argleafID:Int, label: String) {
        
        var is2nd : Bool = false
        
        for leaf in leafPool {
            if leaf.leafID == argleafID {
                leaf.initArg(label)
                
                for obs in observers {
                    if obs.leafID == argleafID {
                        obs.update(label, arg: leaf.getArg(label))
                        break
                    }
                }
                
                if is2nd {
                    return
                } else {
                    is2nd = true
                }
            }
            
            if leaf.leafID == retleafID {
                if leaf.returnType == "Mesh" {
                    globalStack.addLeaf(leaf)
                }
                
                if is2nd {
                    return
                } else {
                    is2nd = true
                }
            }
        }
        
        MintErr.exc.raise(MintEXC.LeafIDNotExist(leafID: argleafID))
    }
    
    func setNewUniqueName(leafID: Int, newName:String) {
        // check 'newName' is unique
        for leaf in leafPool {
            if leaf.name == newName {
                
                MintErr.exc.raise(MintEXC.NameNotUnique(newName: newName, leafID: leafID))
                return
            }
        }
        
        for leaf in leafPool {
            if leaf.leafID == leafID {
                leaf.name = newName
                return
            }
        }
        
        MintErr.exc.raise(MintEXC.LeafIDNotExist(leafID: leafID))
    }
    
    func getLeafUniqueName(leafID: Int) -> String {
        for leaf in leafPool {
            if leaf.leafID == leafID {
                return leaf.name
            }
        }
        
        return "Noname"
    }
    
    func addLeaf(leafType: String, leafID: Int) {
        var newLeaf : Leaf
        
        switch leafType {
        case "Cube":
            newLeaf = Cube(newID: leafID)
        case "Sphere":
            newLeaf = Sphere(newID: leafID)
        case "Cylinder":
            newLeaf = Cylinder(newID: leafID)
        case "Double":
            newLeaf = DoubleLeaf(newID: leafID)
        case "Int":
            newLeaf = IntLeaf(newID: leafID)
        case "String":
            newLeaf = StringLeaf(newID: leafID)
        case "Bool":
            newLeaf = BoolLeaf(newID: leafID)
        case "Vector":
            newLeaf = VectorLeaf(newID: leafID)
        case "SetColor":
            newLeaf = SetColor(newID: leafID)
        case "Subtract":
            newLeaf = Subtract(newID: leafID)
        case "Union":
            newLeaf = Union(newID: leafID)
        case "Intersect":
            newLeaf = Intersect(newID: leafID)
        case "Rotate":
            newLeaf = Rotate(newID: leafID)
        case "RotateAxis":
            newLeaf = RotateAxis(newID: leafID)
        case "Translate":
            newLeaf = Translate(newID: leafID)
        case "Scale":
            newLeaf = Scale(newID: leafID)
        default:
            print("Unknown leaf type alloc requied!")
            newLeaf = Cube(newID: leafID)
        }
        
        leafPool.append(newLeaf)
        if newLeaf.returnType == "Mesh" {
            globalStack.addLeaf(newLeaf)
        }
    }
    
    func removeLeaf(leafID: Int) {
        
        for var i = 0; leafPool.count > i; i++ {
            if leafPool[i].leafID == leafID {
                
                if leafPool[i].returnType == "Mesh" {
                    globalStack.removeAtID(leafID)
                }
                
                // when removed, put arg leaves to view stack
                for arg in leafPool[i].args {
                    if let leaf = arg as? Leaf {
                        if leaf.returnType == "Mesh" {
                            globalStack.addLeaf(leaf)
                        }
                    }
                }
                
                let retLeafID = leafPool[i].retLeafID
                let labels = leafPool[i].retLeafArg
                
                for var i = 0; retLeafID.count > i; i++ {
                    initArgument(retLeafID[i], label: labels[i])
                }
                
                leafPool[i].tellRemoveAllLink()
                
                leafPool.removeAtIndex(i)
                break
            }
        }
    }
    
    func getArgLeafIDs(removeID: Int) -> [Int] {
        
        var result : [Int] = []
        
        for var i = 0; leafPool.count > i; i++ {
            if leafPool[i].leafID == removeID {
                // when removed, put arg leaves to view stack
                for arg in leafPool[i].args {
                    if let leaf = arg as? Leaf {
                        if leaf.returnType == "Mesh" {
                            result += [leaf.leafID]
                        }
                    }
                }
            }
        }
        return result
    }
    
    // loop of reference removed. reset loop check counter
    func loopCleared() {
        for leaf in leafPool {
            leaf.clearLoopCheck()
        }
    }
}

// Root stack of Mint leaves. Provide mesh for 'ModelView'
// This is 'Subject' against view classes as 'Observer'.
class MintGlobalStack:MintSubject {
    private var rootStack = [Leaf]()
    private var observers = [MintObserver]()
    
    // Standard Output for view
    func solveMesh(index: Int) -> (mesh: [Double], normals: [Double], colors: [Float]) {
        var mesh = [Double]()
        var normals = [Double]()
        var colors = [Float]()
        
        if let leafmesh = rootStack[index].solve() as? Mesh {
            mesh = leafmesh.meshArray()
            normals = leafmesh.normalArray()
            colors = leafmesh.colorArray()
        } else {
            //If current leaf does not return 'Mesh', return empty arrays.
            return (mesh: mesh, normals: normals, colors: colors)
        }
        
        return (mesh: mesh, normals: normals, colors: colors)
    }
    
    // Exception output for view
    // func solveException(index: Int) -> MintException {}
    
    func registerObserver(observer: MintObserver) {
        observers.append(observer)
    }
    
    func removeObserver(observer: MintObserver) {
        for var i=0; i < observers.count; i++ {
            
            if observers[i] === observer  {
                observers.removeAtIndex(i)
                break
            }
        }
    }
    
    func solve() {
        for var i = 0; i < observers.count; i++ {
            observers[i].update(self, index: i)
        }
    }
    
    
    // Manipulation interface for 'MintController
    
    func addLeaf(leaf: Leaf) {
        rootStack.append(leaf)
    }
    
    func removeAtID(leafID: Int) {
        for var i = 0; rootStack.count > i; i++ {
            if rootStack[i].leafID == leafID {
                rootStack.removeAtIndex(i)
                break
            }
        }
    }
    
    func hasLeaf(leafID: Int) -> Bool {
        for leaf in rootStack {
            if leaf.leafID == leafID {
                return true
            }
        }
        
        return false
    }
}

*/

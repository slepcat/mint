//
//  MintLeaf.swift
//  MINT
//
//  Created by NemuNeko on 2015/03/08.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

/*

class Leaf {
    let leafID : Int
    var name: String
    
    var needUpdate : Bool {
        set(isUpdate) {
            dirty = isUpdate
        }
        get {
            for arg in args {
                if let leaf = arg as? Leaf {
                    dirty = dirty || leaf.needUpdate
                }
            }
            
            return dirty
        }
    }
    private var dirty : Bool = true
    
    var loopCheck : Bool {
        get {
            loopCount++
            
            if loopCount > retLeafID.count + 1 { // Allow link to multi argument of same leaf
                return true
            }
            
            for arg in args {
                if let leaf = arg as? Leaf {
                    if leaf.loopCheck {
                        return true
                    }
                }
            }
            return false
        }
    }
    private var loopCount : Int = 0
    
    private func clearLoopCount() {
        // Dont call when loopCheck is true. It make app crash.
        loopCount = 0
        
        for arg in args {
            if let leaf = arg as? Leaf {
                leaf.clearLoopCount()
            }
        }
    }
    
    func clearLoopCheck() {
        loopCount = 0
    }
    
    // arguments value
    var args : [Any?]
    var argLabels : [String]
    var argTypes : [String]
    
    //var args : [(label: String, type: String, value: Any?)]
    
    // return value
    var retLeafID : [Int] = []
    var retLeafArg : [String] = []
    var returnType : String
    
    init(newID: Int ){
        leafID = newID
        
        args = []
        argLabels = []
        argTypes = []
        
        returnType = "nil"
        
        name = "null_leaf"
    }
    
    // init argument value. When argument is reference, remove link.
    func initArg(label: String) {
        
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == label {
                if let leaf = args[i] as? Leaf {
                    leaf.linkRemoved(leafID, label:label)
                }
                
                needUpdate = true
            }
        }
    }
    
    // remove reference to leaf which have reference to this instance.
    // Called when link removed
    func linkRemoved(leafID: Int, label: String) {
        for var i = 0; retLeafID.count > i; i++ {
            if retLeafID[i] == leafID && retLeafArg[i] == label {
                retLeafID.removeAtIndex(i)
                retLeafArg.removeAtIndex(i)
                
                needUpdate = true
                
                return
            }
        }
    }
    
    // remove all reference from other leaves when self will be removed.
    // Tell leaves which link to this leaf's return value to kill link.
    func tellRemoveAllLink() {
        for var i = 0; args.count > i; i++ {
            if let leaf = args[i] as? Leaf {
                leaf.linkRemoved(leafID, label: argLabels[i])
            }
        }
    }
    
    // return all arguments
    func getArgs() -> (argLabels: [String], argTypes: [String], args: [Any?]) {
        return (argLabels: argLabels, argTypes: argTypes, args: args)
    }
    
    // set argument value for label
    func getArg(label: String) -> Any? {
        
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == label {
                return args[i]
            }
        }
        
        MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        return nil
    }
    
    // set argument value for label
    func setArg(label: String, value: Any?) {
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == label {
                
                if argTypes[i] == typestr(value) || "nil" == typestr(value) {
                    args[i] = value
                    
                    if let leaf = value as? Leaf {
                        
                        if loopCheck {
                            MintErr.exc.raise(MintEXC.ReferenceLoop(leafName: name, leafID: leafID, argname: argLabels[i]))
                        } else {
                            clearLoopCount()
                        }
                        
                        leaf.retLeafID.append(self.leafID)
                        leaf.retLeafArg.append(argLabels[i])
                    }
                    
                } else {
                    print("type error")
                    MintErr.exc.raise(MintEXC.TypeInvalid(leafName: name, leafID: leafID, argname: argLabels[i],required: argTypes[i], invalid: typestr(value)))
                    return
                }
                
                needUpdate = true
                
                print("argument \(argLabels[i]) of leaf (leafID: \(leafID) is updated to \(value)")
                
                return
            }
        }
        
        MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
    }
    
    func eval(arg: String) -> Any? {
        
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == arg {
                
                let argValue = args[i]
                switch argValue {
                case let someLeaf as Leaf:
                    return someLeaf.solve()
                default:
                    return argValue
                }
            }
        }
        
        return nil
    }
    
    func solve() -> Any? {
        return nil
    }
}

extension Leaf {
    func typestr(value: Any?) -> String {
        
        switch value {
        case let val as Double:
            return "Double"
        case let val as Int:
            return "Int"
        case let val as String:
            return "String"
        case let val as Bool:
            return "Bool"
        case let val as Vector:
            return "Vector"
        case let val as Vertex:
            return "Vertex"
        case let val as Plane:
            return "Plane"
        case let val as Polygon:
            return "Polygon"
        case let val as Mesh:
            return "Mesh"
        case let val as Color:
            return "Color"
        case let val as Leaf:
            return val.returnType
        case nil:
            return "nil"
        default:
            return "unknown"
        }
    }
}

*/
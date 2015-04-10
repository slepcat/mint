//
//  MintLeaf.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/08.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

class Leaf:MintLeaf {
    let leafID : Int
    var name: String
    
    var needUpdate : Bool = true
    
    // arguments value
    var args : [Any?]
    var argLabels : [String]
    var argTypes : [String]
    
    // return value
    var returnTo : [Leaf] = []
    var returnType : String
    
    init(newID: Int ){
        leafID = newID
        
        args = []
        argLabels = []
        argTypes = []
        
        returnType = "nil"
        
        name = "null_leaf"
    }
    
    func getArgs() -> (argLabels: [String], argTypes: [String], args: [Any?]) {
        return (argLabels: argLabels, argTypes: argTypes, args: args)
    }
    
    func setArg(label: String, value: Any) {
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == label {
                
                if argTypes[i] == typestr(value) {
                    args[i] = value
                } else {
                    println("type error")
                    MintErr.exc.raise(MintEXC.TypeInvalid(leafName: name, leafID: leafID, required: argTypes[i], invalid: typestr(value)))
                    return
                }
                
                needUpdate = true
                
                println("argument \(argLabels[i]) of leaf (leafID: \(leafID) is updated to \(value)")
                
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
    func typestr(value: Any) -> String {
        
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
        case let val as Leaf:
            return "Leaf"
        default:
            return "unknown"
        }
    }
}

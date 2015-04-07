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
                
                // type check and exception
                switch value {
                case let val as Double:
                    if argTypes[i] == "Double" {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                case let val as Int:
                    if argTypes[i] == "Int" {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                case let val as String:
                    if argTypes[i] == "String" {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                case let val as Bool:
                    if argTypes[i] == "Bool" {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                case let val as Vector:
                    if argTypes[i] == "Vector" {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                case let val as Vertex:
                    if argTypes[i] == "Vertex" {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                case let val as Plane:
                    if argTypes[i] == "Plane" {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                case let val as Polygon:
                    if argTypes[i] == "Polygon" {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                case let val as Mesh:
                    if argTypes[i] == "Mesh" {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                case let val as Leaf:
                    if argTypes[i] == val.returnType {
                        args[i] = val
                    } else {
                        println("type error")
                    }
                default:
                    println("type error")
                }
                
                needUpdate = true
                
                println("argument \(argLabels[i]) of leaf (leafID: \(leafID) is updated to \(value)")
                
                break
            }
        }
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

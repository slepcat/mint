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
    }
    
    func getArgs() -> (argLabels: [String], argTypes: [String], args: [Any?]) {
        return (argLabels: argLabels, argTypes: argTypes, args: args)
    }
    
    func setArg(label: String, value: Any) {
        for var i = 0; argLabels.count > i; i++ {
            if argLabels[i] == label {
                
                
                // need type check and exception
                args[i] = value
                
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

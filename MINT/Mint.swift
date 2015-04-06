//
//  Mint.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/15.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

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
    
    // set argument
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
                
                break
            }
        }
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
        
        return ([], [], [])
    }
    
    func getReturnType(leafID: Int) -> String {
        for leaf in leafPool {
            if leaf.leafID == leafID {
                return leaf.returnType
            }
        }
        
        return "nil"
    }
    
    func setNewUniqueName(leafID: Int, newName:String) -> Bool {
        // check 'newName' is unique
        for leaf in leafPool {
            if leaf.name == newName {
                return false
            }
        }
        
        for leaf in leafPool {
            if leaf.leafID == leafID {
                leaf.name = newName
                return true
            }
        }
        
        return false
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
        case "Double":
            newLeaf = DoubleLeaf(newID: leafID)
        case "Int":
            newLeaf = IntLeaf(newID: leafID)
        case "String":
            newLeaf = StringLeaf(newID: leafID)
        case "Bool":
            newLeaf = BoolLeaf(newID: leafID)
        default:
            println("Unknown leaf type alloc requied!")
            newLeaf = Cube(newID: leafID)
        }
        
        leafPool.append(newLeaf)
        globalStack.addLeaf(newLeaf)
    }
    
    func removeLeaf(leafID: Int) {
        globalStack.removeAtID(leafID)
        
        for var i = 0; leafPool.count > i; i++ {
            if leafPool[i].leafID == leafID {
                leafPool.removeAtIndex(i)
                break
            }
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
        var normals = [Double()]
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
}

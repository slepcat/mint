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
    
    func getArguments(leafID: Int) -> (argLabels: [String], argTypes:[String], args: [Any?]) {
        for leaf in leafPool {
            if leaf.leafID == leafID {
                return leaf.getArgs()
            }
        }
        
        return ([], [], [])
    }
    
    func addLeaf(leafType: String, leafID: Int) {
        var newLeaf : Leaf?
        
        switch leafType {
        case "Cube":
            newLeaf = Cube(newID: leafID)
        default:
            println("Unknown leaf type alloc requied!")
        }
        
        if let leaf = newLeaf {
            leafPool.append(leaf)
            globalStack.addLeaf(leaf)
        }
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
            }
        }
    }
}

//
//  Mint.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/15.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

// Root level of Mint leaves chains. Should be 'Singleton'?
// This is 'Subject' against view classes as 'Observer'.
class MintInterpreter:MintSubject {
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
    
    func removeLeaf(leaf: Leaf) {
        for var i=0; i < rootStack.count; i++ {
            if leaf === rootStack[i] {
                rootStack.removeAtIndex(i)
            }
        }
    }
    
    func removeAtIndex(index: Int) {
        if index < rootStack.count && index >= 0 {
            rootStack.removeAtIndex(index)
        }
    }
}

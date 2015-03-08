//
//  MintLeafPrimitives.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/09.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

// Primitive class
// Base class for all primitive solids. For example, cube, sphere, cylinder, and so on.

class Primitive:Leaf, MintLeaf {
    var mesh:Mesh? = nil
    var center:Vertex = (Vertex(pos: Vector(x: 0, y: 0, z: 0)))
    
    func reInitArg() {
        center = (Vertex(pos: Vector(x: 0, y: 0, z: 0)))
    }
    
    
}

class cube:Primitive{
    var width : Any = 10.0
    var height : Any = 10.0
    var depth : Any = 10.0
    
    override func reInitArg() {
        super.reInitArg()
        width = 10.0
        height = 10.0
        depth = 10.0
    }
    
    override func solve() -> Any {
        
        
        return mesh
    }
}
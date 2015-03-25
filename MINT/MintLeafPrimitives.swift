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
    var mesh:Any = NSNull()
    var center:Any = Vertex(pos: Vector(x: 0, y: 0, z: 0))
    
    func reInitArg() {
        center = (Vertex(pos: Vector(x: 0, y: 0, z: 0)))
    }
    
    
}

class Cube:Primitive ,MintLeaf{
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
        //type cast args
        let width = eval(self.width) as Double
        let height = eval(self.height) as Double
        let depth = eval(self.depth) as Double
        let center = eval(self.center) as Vertex
        
        let left = -width/2 + center.pos.x
        let right = width/2 + center.pos.x
        let front = -depth/2 + center.pos.z
        let back = depth/2 + center.pos.z
        let bottom = -height/2 + center.pos.y
        let top = height/2 + center.pos.y
        
        var vertices : [Vertex] = []
        
        vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))] //bottom
        vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
        vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
        vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
        vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
        vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]

        vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))] // front
        vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
        vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
        vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
        vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
        vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
        
        vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))] //right
        vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
        vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
        vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
        vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
        vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
        
        vertices += [Vertex(pos: Vector(x: right, y: back, z: top))] // back
        vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
        vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
        vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
        vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
        vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
        
        vertices += [Vertex(pos: Vector(x: left, y: back, z: top))] //left
        vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
        vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
        vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
        vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
        vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
        
        vertices += [Vertex(pos: Vector(x: right, y: back, z: top))] // top
        vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
        vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
        vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
        vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
        vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
        
        var poly : [Polygon] = []
        
        for var i = 0; i < vertices.count; i += 3 {
            poly += [Polygon(vertices: [vertices[i], vertices[i + 1], vertices[i + 2]], shared: 0)]
        }
        
        mesh = Mesh(m: poly)
        
        return mesh
    }
}
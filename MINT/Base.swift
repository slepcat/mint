//
//  Base.swift
//  MINT
//
//  Created by 安藤 泰造 on 2014/12/15.
//  Copyright (c) 2014年 Taizo A. All rights reserved.
//

import Foundation

// # struct Vector
// Represents a 3D vector.
//
// Example usage:
//
//     new Vector(x: 1,y: 2,z: 3)
//     new Vector([1, 2, 3])
//     new Vector(x: 1, y: 2) // assumes z=0
//     new Vector([1, 2]) // assumes z=0

struct Vector {
    let x:Double
    let y:Double
    let z:Double
    
    init(x:Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(x:Double, y:Double) {
        self.x = x
        self.y = y
        self.z = 0
    }
    
    init(vector:Vector) {
        self = vector
    }
    
    init(_ array:[Double]) {
        switch array.count {
        case 0:
            self.x = 0
            self.y = 0
            self.z = 0
        case 1:
            self.x = array[0]
            self.y = array[0]
            self.z = array[0]
        case 2:
            self.x = array[0]
            self.y = array[1]
            self.z = 0
        default:
            self.x = array[0]
            self.y = array[1]
            self.z = array[2]
        }
    }
    
    func negated() -> Vector {
        return Vector(x:-self.x, y:-self.y, z:-self.z)
    }
    
    func abs() -> Vector {
        return Vector(x: fabs(self.x) , y: fabs(self.y) , z: fabs(self.z))
    }
    
    func times(k:Double) -> Vector {
        return Vector(x: k * self.x, y: k * self.y , z: k * self.z)
    }
    
    func dividedBy(k: Double) -> Vector {
        return Vector(x: self.x / k , y: self.y / k , z: self.z / k)
    }
    
    func dot(a: Vector) -> Double {
        return (self.x * a.x) + (self.y * a.y) + (self.z * a.z)
    }
    
    func cross(a: Vector) -> Vector {
        return Vector(x: self.y * a.z - self.z * a.y,y: self.z * a.x - self.x * a.z,z: self.x * a.y - self.y * a.x)
    }
    
    func lerp(vector a: Vector, k: Double) -> Vector {
        return Vector(vector: self + (a - self).times(k))
    }
    
    func lengthSquared() -> Double {
        return self.dot(self);
    }
    
    func length() -> Double {
        return sqrt(lengthSquared())
    }
    
    func unit() -> Vector {
        return self.dividedBy(self.length())
    }
    
    func distanceTo(a: Vector) -> Double {
        return (self - a).length()
    }
    
    func distanceToSquared(a: Vector) -> Double {
        return (self - a).lengthSquared()
    }
    
    func equals(a: Vector) -> Bool {
        return ((self.x == a.x) && (self.y == a.y) && (self.z == a.z))
    }
    
    /*
    // Right multiply by a 4x4 matrix (the vector is interpreted as a row vector)
    // Returns a new CSG.Vector3D
    multiply4x4: function(matrix4x4) {
    return matrix4x4.leftMultiply1x3Vector(this);
    },
    
    transform: function(matrix4x4) {
    return matrix4x4.leftMultiply1x3Vector(this);
    }
    */
    
    func toStlString() -> String {
        return "\(self.x) \(self.y) \(self.z)"
    }
    
    func toAMFString() -> String {
        return "<x>\(self.x)</x><y>\(self.y)</y><z>\(self.z)</z>"
    }
    
    func toString() -> String {
        return "(\(self.x), \(self.y), \(self.z))" //need to add fixedTo()
    }
    
    // find a vector that is somewhat perpendicular to this one
    func randomNonParallelVector() -> Vector {
        let abs = self.abs()
        
        if (abs.x <= abs.y) && (abs.x <= abs.z) {
            return Vector(x: 1,y: 0,z: 0)
        } else if (abs.y <= abs.x) && (abs.y <= abs.z) {
            return Vector(x: 0,y: 1,z: 0)
        } else {
            return Vector(x: 0,y: 0,z: 1)
        }
    }
    
    func min(a: Vector) -> Vector {
        return Vector(x: fmin(self.x, a.x), y: fmin(self.y, a.y), z: fmin(self.z, a.z))
    }
    
    func max(a: Vector) -> Vector {
        return Vector(x: fmax(self.x, a.x), y: fmax(self.y, a.y),z: fmax(self.z, a.z))
    }
}

func + (left: Vector, right:Vector) -> Vector {
    return Vector(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}

func - (left: Vector, right:Vector) -> Vector {
    return Vector(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}

// # struct Vertex
// Represents a vertex of a polygon. Use your own vertex class instead of this
// one to provide additional features like texture coordinates and vertex
// colors. Custom vertex classes need to provide a `pos` property
// `flipped()`, and `interpolate()` methods that behave analogous to the ones
// defined by `CSG.Vertex`.

struct Vertex {
    let pos:Vector
    var tag:Int = Tag.get.newTag
    
    // defined by `CSG.Vertex`.
    init(pos: Vector) {
        self.pos = pos
    }
    
    // create from an untyped object with identical property names:
    init(fromObject obj:Vector) {
        self.pos = obj
    }
    
    // Return a vertex with all orientation-specific data (e.g. vertex normal) flipped. Called when the
    // orientation of a polygon is flipped.
    func flipped() -> Vertex {
        return self
    }
    
    func getTag() -> Int {
        return self.tag
    }
    
    // Create a new vertex between this vertex and `other` by linearly
    // interpolating all properties using a parameter of `t`. Subclasses should
    // override this to interpolate additional properties.
    func interpolate(other: Vertex, t: Double) -> Vertex {
        var newpos = self.pos.lerp(vector: other.pos, k: t)
        return Vertex(pos: newpos)
    }
    
    /*
    // Affine transformation of vertex. Returns a new CSG.Vertex
    func transform(matrix: matrix4x4) -> Vertex {
        var newpos = this.pos.multiply4x4(matrix4x4);
        
        return new Vertex(pos: newpos)
    }
    */
    
    func toStlString() -> String {
        return "vertex " + self.pos.toStlString() + "\n"
    }
    
    func toAMFString() -> String {
        return "<vertex><coordinates>" + self.pos.toAMFString() + "</coordinates></vertex>\n"
    }
    
    func toString() -> String {
        return self.pos.toString()
    }
}
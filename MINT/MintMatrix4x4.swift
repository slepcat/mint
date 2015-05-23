//
//  MintMatrix4x4.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/05/10.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation


func + (left: Matrix4x4, right: Matrix4x4) -> Matrix4x4 {
    var r : [Double] = []
    for var i = 0; i < 16; i++ {
        r[i] = left.elements[i] + right.elements[i]
    }
    return Matrix4x4(matrix: r)
}

func - (left: Matrix4x4, right: Matrix4x4) -> Matrix4x4 {
    var r : [Double] = []
    for var i = 0; i < 16; i++ {
        r[i] = left.elements[i] - right.elements[i]
    }
    return Matrix4x4(matrix: r)
}

// right multiply by another 4x4 matrix:
func * (left: Matrix4x4, right: Matrix4x4) -> Matrix4x4 {
    // cache elements in local variables, for speedup:
    var result = [Double](count: 16, repeatedValue: 0.0)
    
    result[0] = left.elements[0] * right.elements[0] + left.elements[1] * right.elements[4] + left.elements[2] * right.elements[8] + left.elements[3] * right.elements[12]
    result[1] = left.elements[0] * right.elements[1] + left.elements[1] * right.elements[5] + left.elements[2] * right.elements[9] + left.elements[3] * right.elements[13]
    result[2] = left.elements[0] * right.elements[2] + left.elements[1] * right.elements[6] + left.elements[2] * right.elements[10] + left.elements[3] * right.elements[14]
    result[3] = left.elements[0] * right.elements[3] + left.elements[1] * right.elements[7] + left.elements[2] * right.elements[11] + left.elements[3] * right.elements[15];
    result[4] = left.elements[4] * right.elements[0] + left.elements[5] * right.elements[4] + left.elements[6] * right.elements[8] + left.elements[7] * right.elements[12]
    result[5] = left.elements[4] * right.elements[1] + left.elements[5] * right.elements[5] + left.elements[6] * right.elements[9] + left.elements[7] * right.elements[13]
    result[6] = left.elements[4] * right.elements[2] + left.elements[5] * right.elements[6] + left.elements[6] * right.elements[10] + left.elements[7] * right.elements[14]
    result[7] = left.elements[4] * right.elements[3] + left.elements[5] * right.elements[7] + left.elements[6] * right.elements[11] + left.elements[7] * right.elements[15]
    result[8] = left.elements[8] * right.elements[0] + left.elements[9] * right.elements[4] + left.elements[10] * right.elements[8] + left.elements[11] * right.elements[12]
    result[9] = left.elements[8] * right.elements[1] + left.elements[9] * right.elements[5] + left.elements[10] * right.elements[9] + left.elements[11] * right.elements[13]
    result[10] = left.elements[8] * right.elements[2] + left.elements[9] * right.elements[6] + left.elements[10] * right.elements[10] + left.elements[11] * right.elements[14]
    result[11] = left.elements[8] * right.elements[3] + left.elements[9] * right.elements[7] + left.elements[10] * right.elements[11] + left.elements[11] * right.elements[15]
    result[12] = left.elements[12] * right.elements[0] + left.elements[13] * right.elements[4] + left.elements[14] * right.elements[8] + left.elements[15] * right.elements[12]
    result[13] = left.elements[12] * right.elements[1] + left.elements[13] * right.elements[5] + left.elements[14] * right.elements[9] + left.elements[15] * right.elements[13]
    result[14] = left.elements[12] * right.elements[2] + left.elements[13] * right.elements[6] + left.elements[14] * right.elements[10] + left.elements[15] * right.elements[14]
    result[15] = left.elements[12] * right.elements[3] + left.elements[13] * right.elements[7] + left.elements[14] * right.elements[11] + left.elements[15] * right.elements[15]
    
    return Matrix4x4(matrix: result)
}

// Right multiply the matrix by a Vector (interpreted as 3 row, 1 column)
// (result = M*v)
// Fourth element is taken as 1
func * (left: Matrix4x4, right: Vector) -> Vector {
    
    let v3 : Double = 1.0
    var x = right.x * left.elements[0] + right.y * left.elements[1] + right.z * left.elements[2] + v3 * left.elements[3]
    var y = right.x * left.elements[4] + right.y * left.elements[5] + right.z * left.elements[6] + v3 * left.elements[7]
    var z = right.x * left.elements[8] + right.y * left.elements[9] + right.z * left.elements[10] + v3 * left.elements[11]
    var w = right.x * left.elements[12] + right.y * left.elements[13] + right.z * left.elements[14] + v3 * left.elements[15]
    // scale such that fourth element becomes 1:
    if w != 1.0 {
        let invw = 1.0 / w
        x *= invw
        y *= invw
        z *= invw
    }
    return Vector(x: x, y: y, z: z)
}

// Multiply a Vector (interpreted as 3 column, 1 row) by this matrix
// (result = v*M)
// Fourth element is taken as 1
func * (left: Vector, right: Matrix4x4) -> Vector {
    
    let v3 : Double = 1
    var x = left.x * right.elements[0] + left.y * right.elements[4] + left.z * right.elements[8] + v3 * right.elements[12]
    var y = left.x * right.elements[1] + left.y * right.elements[5] + left.z * right.elements[9] + v3 * right.elements[13]
    var z = left.x * right.elements[2] + left.y * right.elements[6] + left.z * right.elements[10] + v3 * right.elements[14]
    var w = left.x * right.elements[3] + left.y * right.elements[7] + left.z * right.elements[11] + v3 * right.elements[15]
    // scale such that fourth element becomes 1:
    if w != 1 {
        let invw = 1.0 / w
        x *= invw
        y *= invw
        z *= invw
    }
    return Vector(x: x, y: y, z: z)
}

/*
// Right multiply the matrix by a Vector2D (interpreted as 3 row, 1 column)
// (result = M*v)
// Fourth element is taken as 1
func * (left: Matrix4x4, right: Vector2D) -> Vector2D {
    
    let v2 : Double = 0
    let v3 : Double = 1.0
    var x = right.x * left.elements[0] + right.y * left.elements[1] + v2 * left.elements[2] + v3 * left.elements[3]
    var y = right.x * left.elements[4] + right.y * left.elements[5] + v2 * left.elements[6] + v3 * left.elements[7]
    var z = right.x * left.elements[8] + right.y * left.elements[9] + v2 * left.elements[10] + v3 * left.elements[11]
    var w = right.x * left.elements[12] + right.y * left.elements[13] + v2 * left.elements[14] + v3 * left.elements[15]
    // scale such that fourth element becomes 1:
    if w != 1 {
        let invw = 1.0 / w
        x *= invw
        y *= invw
        z *= invw
    }
    return Vector(x: x, y: y, z: 0)
}

// Multiply a Vector2D (interpreted as 3 column, 1 row) by this matrix
// (result = v*M)
// Fourth element is taken as 1
func * (left: Vector2D, right: Matrix4x4) -> Vector2D {
    
    let v2 : Double = 0
    let v3 : Double = 1
    var x = left.x * right.elements[0] + left.y * right.elements[4] + v2 * right.elements[8] + v3 * right.elements[12]
    var y = left.x * right.elements[1] + left.y * right.elements[5] + v2 * right.elements[9] + v3 * right.elements[13]
    var z = left.x * right.elements[2] + left.y * right.elements[6] + v2 * right.elements[10] + v3 * right.elements[14]
    var w = left.x * right.elements[3] + left.y * right.elements[7] + v2 * right.elements[11] + v3 * right.elements[15]
    // scale such that fourth element becomes 1:
    if w != 1 {
        let invw = 1.0 / w
        x *= invw
        y *= invw
        z *= invw
    }
    return Vector(x: x, y: y, z: 0)
}
*/

//////////
// # struct Matrix4x4:
// Represents a 4x4 matrix. Elements are specified in row order

struct Matrix4x4 {
    
    private var matrix : [Double]
    
    var elements : [Double] {
        get {
            return matrix
        }
    }
    
    init(matrix: [Double]) {
        
        if matrix.count == 16 {
            self.matrix = matrix
        } else {
            self.matrix = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
        }
    }
    
    // determine whether this matrix is a mirroring transformation
    func isMirroring() -> Bool {
        let u = Vector(x: elements[0], y: elements[4], z: elements[8])
        let v = Vector(x: elements[1], y: elements[5], z: elements[9])
        let w = Vector(x: elements[2], y: elements[6], z: elements[10])
        
        // for a true orthogonal, non-mirrored base, u.cross(v) == w
        // If they have an opposite direction then we are mirroring
        let mirrorvalue = u.cross(v).dot(w)
        return (mirrorvalue < 0)
    }
    
    
    // return the unity matrix
    static func unity() -> Matrix4x4 {
        return Matrix4x4(matrix: [])
    }
    
    // Create a rotation matrix for rotating around the x axis
    static func rotationX(angle : Double) -> Matrix4x4 {
        let rad = angle * M_PI / 180.0
        let els = [1, 0, 0, 0, 0, cos(rad), sin(rad), 0, 0, -sin(rad), cos(rad), 0, 0, 0, 0, 1]
        return Matrix4x4(matrix: els)
    }
    
    // Create a rotation matrix for rotating around the y axis
    static func rotationY(angle: Double) -> Matrix4x4 {
        let rad = angle * M_PI / 180.0
        let els = [cos(rad), 0, -sin(rad), 0, 0, 1, 0, 0, sin(rad), 0, cos(rad), 0, 0, 0, 0, 1]
        return Matrix4x4(matrix: els)
    }
    
    // Create a rotation matrix for rotating around the z axis
    static func rotationZ(angle: Double) -> Matrix4x4 {
        let rad = angle * M_PI / 180.0
        let els = [cos(rad), sin(rad), 0, 0, -sin(rad), cos(rad), 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
        return Matrix4x4(matrix: els)
    }
    
    // Matrix for rotation about arbitrary point and axis
    static func rotation(rotationCenter: Vector, rotationAxis: Vector, degrees: Double) -> Matrix4x4 {
        
        var rotationPlane = Plane(normal: rotationAxis, point: rotationCenter)
        var orthobasis = OrthoNormalBasis(plane: rotationPlane, rightvector: nil)
        var transformation = translation(rotationCenter.negated())
        
        transformation = transformation * orthobasis.getProjectionMatrix()
        transformation = transformation * rotationZ(degrees)
        transformation = transformation * orthobasis.getInverseProjectionMatrix()
        transformation = transformation * translation(rotationCenter)
        
        return transformation
    }
    
    // Create an affine matrix for translation:
    static func translation(trans: Vector) -> Matrix4x4 {
        let els = [1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            trans.x, trans.y, trans.z, 1]
        return Matrix4x4(matrix: els)
    }
    
    // Create an affine matrix for mirroring into an arbitrary plane:
    static func mirroring(plane: Plane) -> Matrix4x4 {
        let nx = plane.normal.x
        let ny = plane.normal.y
        let nz = plane.normal.z
        let w = plane.w
        let els = [
            (1.0 - 2.0 * nx * nx), (-2.0 * ny * nx), (-2.0 * nz * nx), 0,
            (-2.0 * nx * ny), (1.0 - 2.0 * ny * ny), (-2.0 * nz * ny), 0,
            (-2.0 * nx * nz), (-2.0 * ny * nz), (1.0 - 2.0 * nz * nz), 0,
            (-2.0 * nx * w), (-2.0 * ny * w), (-2.0 * nz * w), 1
        ]
        return Matrix4x4(matrix: els)
    }
    
    // Create an affine matrix for scaling:
    static func scaling(scale: Vector) -> Matrix4x4 {
        let els = [scale.x, 0, 0, 0, 0, scale.y, 0, 0, 0, 0, scale.z, 0, 0, 0, 0, 1]
        return Matrix4x4(matrix: els)
    }
}

// # class OrthoNormalBasis
// Reprojects points on a 3D plane onto a 2D plane
// or from a 2D plane back onto the 3D plane
class OrthoNormalBasis {
    
    var v : Vector
    var u : Vector
    var plane : Plane
    var planeorigin : Vector
    
    init(plane: Plane, rightvector: Vector?) {
        
        let rightvec : Vector
        
        if let vec = rightvector {
            rightvec = vec
        } else {
            // choose an arbitrary right hand vector, making sure it is somewhat orthogonal to the plane normal:
            rightvec = plane.normal.randomNonParallelVector()
        }
        
        v = plane.normal.cross(rightvec).unit()
        u = v.cross(plane.normal)
        self.plane = plane
        planeorigin = plane.normal.times(plane.w)
    }

    // The z=0 plane, with the 3D x and y vectors mapped to the 2D x and y vector
    static func Z0Plane() -> OrthoNormalBasis {
        var plane = Plane(normal: Vector(x: 0, y: 0, z: 1), w: 0)
        return OrthoNormalBasis(plane: plane, rightvector: Vector(x: 1, y: 0, z: 0))
    }

    func getProjectionMatrix() -> Matrix4x4 {
        return Matrix4x4(matrix: [
            u.x, v.x, plane.normal.x, 0,
            u.y, v.y, plane.normal.y, 0,
            u.z, v.z, plane.normal.z, 0,
            0, 0, -plane.w, 1])
    }
    
    func getInverseProjectionMatrix() -> Matrix4x4 {
        var p = plane.normal.times(plane.w)
        return Matrix4x4(matrix: [
            u.x, u.y, u.z, 0,
            v.x, v.y, v.z, 0,
            plane.normal.x, plane.normal.y, plane.normal.z, 0,
            p.x, p.y, p.z, 1])
    }
    
    func to2D(vec3: Vector) -> Vector2D {
        return Vector2D(x: vec3.dot(u), y: vec3.dot(v))
    }
    
    func to3D(vec2: Vector2D) -> Vector {
        return planeorigin + u.times(vec2.x) + v.times(vec2.y)
    }
    
    /* line classes not implemented yet
    func line3Dto2D(line3d: Line) -> Line2D {
        var a = line3d.point
        var b = line3d.direction + a
        var a2d = to2D(a)
        var b2d = to2D(b)
        return Line2D.fromPoints(a2d, b2d)
    }
    
    func line2Dto3D(line2d: Line2D) -> Line {
        var a = line2d.origin()
        var b = line2d.direction() + a
        var a3d = to3D(a)
        var b3d = to3D(b)
        return Line.fromPoints(a3d, b3d)
    }*/
    
    func transform(matrix: Matrix4x4) -> OrthoNormalBasis {
        // todo: this may not work properly in case of mirroring
        var newplane = plane.transform(matrix)
        var rightpoint_transformed = u.transform(matrix)
        var origin_transformed = Vector(x: 0, y: 0, z: 0).transform(matrix)
        var newrighthandvector = rightpoint_transformed - origin_transformed
        return OrthoNormalBasis(plane: newplane, rightvector: newrighthandvector)
    }
}


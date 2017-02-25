//
//  MintGLUtility.swift
//  MINT
//
//  Created by NemuNeko on 2017/02/05.
//  Copyright © 2017年 Taizo A. All rights reserved.
//

//  In Swift 3.0, SGLMath is not available and I need original implementaion. Arg!

import Foundation

struct mat4 {
    private var value : [Float] = [Float](repeating: 0, count:16)
    
    subscript(index: Int) -> Float {
        get {
            let i = index % 16
            return value[i]
        }
        
        set(newValue) {
            let i = index % 16
            value[i] = newValue
        }
    }
    
    init(_ v: Float) {
        value = [Float](repeating: v, count: 16)
    }
    
    init(_ m: mat4) {
        for i in stride(from: 0, to: 16, by: 1) {
            value[i] = m[i]
        }
    }
    
    init(_ a: [Float]) {
        for i in stride(from: 0, to: 16, by: 1) {
            value[i] = a[i]
        }
    }
    
    init() {
        value = [1,0,0,0,
                 0,1,0,0,
                 0,0,1,0,
                 0,0,0,1]
    }
    
    func arrayf() -> [Float] {
        return value
    }
    
    static func identity() -> mat4 { return mat4() }
}

func * (left: mat4, right: mat4) -> mat4 {
    // cache elements in local variables, for speedup:
    var result = [Float](repeating: 0.0, count: 16)
    
    // [ 0,  1,  2,  3]   [ 0,  1,  2,  3]
    // [ 4,  5,  6,  7] * [ 4,  5,  6,  7]
    // [ 8,  9, 10, 11]   [ 8,  9, 10, 11]
    // [12, 13, 14, 15]   [12, 13, 14, 15]
    /*
    
    result[0] = left[0] * right[0] + left[1] * right[4] + left[2] * right[8] + left[3] * right[12]
    result[1] = left[0] * right[1] + left[1] * right[5] + left[2] * right[9] + left[3] * right[13]
    result[2] = left[0] * right[2] + left[1] * right[6] + left[2] * right[10] + left[3] * right[14]
    result[3] = left[0] * right[3] + left[1] * right[7] + left[2] * right[11] + left[3] * right[15]
    
    result[4] = left[4] * right[0] + left[5] * right[4] + left[6] * right[8] + left[7] * right[12]
    result[5] = left[4] * right[1] + left[5] * right[5] + left[6] * right[9] + left[7] * right[13]
    result[6] = left[4] * right[2] + left[5] * right[6] + left[6] * right[10] + left[7] * right[14]
    result[7] = left[4] * right[3] + left[5] * right[7] + left[6] * right[11] + left[7] * right[15]
    
    result[8] = left[8] * right[0] + left[9] * right[4] + left[10] * right[8] + left[11] * right[12]
    result[9] = left[8] * right[1] + left[9] * right[5] + left[10] * right[9] + left[11] * right[13]
    result[10] = left[8] * right[2] + left[9] * right[6] + left[10] * right[10] + left[11] * right[14]
    result[11] = left[8] * right[3] + left[9] * right[7] + left[10] * right[11] + left[11] * right[15]
    
    result[12] = left[12] * right[0] + left[13] * right[4] + left[14] * right[8] + left[15] * right[12]
    result[13] = left[12] * right[1] + left[13] * right[5] + left[14] * right[9] + left[15] * right[13]
    result[14] = left[12] * right[2] + left[13] * right[6] + left[14] * right[10] + left[15] * right[14]
    result[15] = left[12] * right[3] + left[13] * right[7] + left[14] * right[11] + left[15] * right[15]
    */
    // [ 0,  4,  8, 12]   [ 0,  4,  8, 12]
    // [ 1,  5,  9, 13] * [ 1,  5,  9, 13]
    // [ 2,  6, 10, 14]   [ 2,  6, 10, 14]
    // [ 3,  7, 11, 15]   [ 3,  7, 11, 15]

    result[0] = left[0] * right[0] + left[4] * right[1] + left[8] * right[2] + left[12] * right[3]
    result[4] = left[0] * right[4] + left[4] * right[5] + left[8] * right[6] + left[12] * right[7]
    result[8] = left[0] * right[8] + left[4] * right[9] + left[8] * right[10] + left[12] * right[11]
    result[12] = left[0] * right[12] + left[4] * right[13] + left[8] * right[14] + left[12] * right[15]
    
    result[1] = left[1] * right[0] + left[5] * right[1] + left[9] * right[2] + left[13] * right[3]
    result[5] = left[1] * right[4] + left[5] * right[5] + left[9] * right[6] + left[13] * right[7]
    result[9] = left[1] * right[8] + left[5] * right[9] + left[9] * right[10] + left[13] * right[11]
    result[13] = left[1] * right[12] + left[5] * right[13] + left[9] * right[14] + left[13] * right[15]
    
    result[2] = left[2] * right[0] + left[6] * right[1] + left[10] * right[2] + left[14] * right[3]
    result[6] = left[2] * right[4] + left[6] * right[5] + left[10] * right[6] + left[14] * right[7]
    result[10] = left[2] * right[8] + left[6] * right[9] + left[10] * right[10] + left[14] * right[11]
    result[14] = left[2] * right[12] + left[6] * right[13] + left[10] * right[14] + left[14] * right[15]
    
    result[3] = left[3] * right[0] + left[7] * right[1] + left[11] * right[2] + left[15] * right[3]
    result[7] = left[3] * right[4] + left[7] * right[5] + left[11] * right[6] + left[15] * right[7]
    result[11] = left[3] * right[8] + left[7] * right[9] + left[11] * right[10] + left[15] * right[11]
    result[15] = left[3] * right[12] + left[7] * right[13] + left[11] * right[14] + left[15] * right[15]
    
    return mat4(result)
}

struct vec3 {
    private var value : [Float] = [Float](repeating: 0, count:3)
    
    subscript(index: Int) -> Float {
        get {
            let i = index % 3
            return value[i]
        }
        
        set(newValue) {
            let i = index % 3
            value[i] = newValue
        }
    }
    
    init(_ v: Float) {
        value = [Float](repeating: v, count: 3)
    }
    
    init(_ v: vec3) {
        for i in stride(from: 0, to: 3, by: 1) {
            value[i] = v[i]
        }
    }
    
    init(_ a: Float, _ b: Float, _ c: Float) {
        value[0] = a
        value[1] = b
        value[2] = c
    }
    
    init(_ a: [Float]) {
        for i in stride(from: 0, to: 3, by: 1) {
            value[i] = a[i]
        }
    }

    func arrayf() -> [Float] {
        return value
    }
    
    func to_vec4() -> vec4 {
        return vec4(value[0], value[1], value[2], 1)
    }
    
    func dividedBy(_ k: Float) -> vec3 {
        return vec3(value[0] / k , value[1] / k, value[2] / k)
    }
    
    func dot(_ a: vec3) -> Float {
        return (value[0] * a[0]) + (value[1] * a[1]) + (value[2] * a[2])
    }
    
    func lengthSquared() -> Float {
        return self.dot(self)
    }
    
    func length() -> Float {
        return sqrt(self.lengthSquared())
    }
    
    func normalize() -> vec3 {
        return self.dividedBy(self.length())
    }
}

struct vec4 {
    private var value : [Float] = [Float](repeating: 0, count:4)
    
    subscript(index: Int) -> Float {
        get {
            let i = index % 4
            return value[i]
        }
        
        set(newValue) {
            let i = index % 4
            value[i] = newValue
        }
    }
    
    init(_ v: Float) {
        value = [Float](repeating: v, count: 4)
    }
    
    init(_ v: vec4) {
        for i in stride(from: 0, to: 4, by: 1) {
            value[i] = v[i]
        }
    }
    
    init(_ a: Float, _ b: Float, _ c: Float, _ d: Float) {
        value = [a, b, c, d]
    }
    
    init(_ a: [Float]) {
        for i in stride(from: 0, to: 4, by: 1) {
            value[i] = a[i]
        }
    }
    
    func to_vec3() -> vec3 {
        return vec3(value[0], value[1], value[2])
    }
    
    func arrayf() -> [Float] {
        return value
    }
}

func mint_translate(_ m:mat4, _ v:vec3) -> mat4
{
    var result = mat4(m)
    
    result[12] = v[0]
    result[13] = v[1]
    result[14] = v[2]

    return result
}

func mint_perspective(_ fovy:Float, _ aspect:Float, _ zNear:Float, _ zFar:Float) -> mat4 {
    // Right Handed
    let tanHalfFovy = tan(fovy / 2)
    
    let r00:Float = 1 / (aspect * tanHalfFovy)
    let r11:Float = 1 / (tanHalfFovy)
    
    var r22:Float, r32:Float
    
    r22 = -(zFar + zNear) / (zFar - zNear)
    r32 = -(2 * zFar * zNear)
    r32 /= (zFar - zNear)
    
    return mat4([
        r00, 0,   0,   0,
        0,   r11, 0,   0,
        0,   0,   r22, -1,
        0,   0,   r32, 0
    ])
}

func rotateSlow(_ m:mat4, _ angle:Float, _ v:vec3) -> mat4 {
    let a = angle
    let c = cos(a)
    let s = sin(a)
    
    let axis = v.normalize()
    
    var r00 = c
    r00 += (1 - c) * axis[0] * axis[0]
    var r01 = (1 - c) * axis[0] * axis[1]
    r01 += s * axis[2]
    var r02 = (1 - c) * axis[0] * axis[2]
    r02 -= s * axis[1]
    
    var r10 = (1 - c) * axis[1] * axis[0]
    r10 -= s * axis[2]
    var r11 = c
    r11 += (1 - c) * axis[1] * axis[1]
    var r12 = (1 - c) * axis[1] * axis[2]
    r12 += s * axis[0]
    
    var r20 = (1 - c) * axis[2] * axis[0]
    r20 += s * axis[1]
    var r21 = (1 - c) * axis[2] * axis[1]
    r21 -= s * axis[0]
    var r22 = c
    r22 += (1 - c) * axis[2] * axis[2];
    
    return mat4([
        r00, r01, r02, 0,
        r10, r11, r12, 0,
        r20, r21, r22, 0,
        0,   0,   0,   1
    ])
    
}

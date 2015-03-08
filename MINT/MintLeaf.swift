//
//  MintLeaf.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/08.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

class Leaf:MintLeaf {
    func eval(arg: Any) -> Any {
        
        // If 'arg' is numeric value, return it as 'Any' type.
        // If 'arg' is 'Leaf' instance, call solve() method.
        switch arg {
        case let someInt as Int:
            return someInt
        case let someDouble as Double:
            return someDouble
        case let someVertex as Vertex:
            return someVertex
        case let someVector as Vector:
            return someVector
        case let somePolygon as Polygon:
            return somePolygon
        case let someMesh as Mesh:
            return someMesh
        case let someLeaf as Leaf:
            return someLeaf.solve()
        default:
            println("Unexpected type varialbe")
            return 0
        }
    }
    
    func solve() -> Any {
        return 0
    }
}
// Playground - noun: a place where people can play

import Foundation
//import Cocoa
import OpenGL


class Leaf {
    func eval(arg: Any) -> Any {
        
        // If 'arg' is numeric value, return it as 'Any' type.
        // If 'arg' is 'Leaf' instance, call solve() method.
        switch arg {
        case let someInt as Int:
            return someInt
        case let someDouble as Double:
            return someDouble
        /*case let someVertex as Vertex:
            return someVertex
        case let someVector as Vector:
            return someVector
        case let somePolygon as Polygon:
            return somePolygon
        case let someMesh as Mesh:
            return someMesh*/
        case let someLeaf as Leaf:
            return someLeaf.solve()
        default:
            println("Unexpected type varialbe")
            return  NSNull()
        }
    }
    
    func solve() -> Any {
        return  NSNull()
    }
}

class plus:Leaf {
    var arga:Any = 10
    var argb:Int? = 5
    
    override func solve() -> Any {
        let a =  eval(arga) as? Int
        let b = eval(argb) as? Int
        
        if a != nil && b != nil  {
            return a! + b!
        }
        
        return NSNull()
    }
}

var f = plus()
var e = plus()
let c = f.solve()

e.arga = f

let h = e.solve()




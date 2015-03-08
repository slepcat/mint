// Playground - noun: a place where people can play

import Foundation
import Cocoa
import OpenGL


// Enum difinition for BSP /Boolean operation
// You cannot change order of cases because Planer.splitPolygon use it.
enum BSP : Int {
    case Coplanar = 0, Front, Back, Spanning, Coplanar_front, Coplanar_back
}

let ti = BSP.Back
let tj = BSP.Front



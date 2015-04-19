// Playground - noun: a place where people can play

import Foundation
import Cocoa


var argPoint = NSPoint()
var retPoint = NSPoint()


let path : NSBezierPath = NSBezierPath()
    
let argPtLocal = NSPoint(x: 0, y: 50)
let retPtLocal = NSPoint(x: 80, y: 0)

let bounds : NSRect = NSRect(origin: NSPoint(x: 0, y: 0), size: CGSize(width: 80, height: 50))

path.moveToPoint(argPtLocal)
    
let ctpt1 : NSPoint
let ctpt2 : NSPoint
    
if argPtLocal.x <= retPtLocal.x {
    ctpt1 = NSPoint(x: bounds.width * 0.55, y: argPtLocal.y)
    ctpt2 = NSPoint(x: bounds.width * 0.45, y: retPtLocal.y)
} else {
    if argPtLocal.y <= retPtLocal.y {
        ctpt1 = NSPoint(x: argPtLocal.x, y: bounds.height * 0.55)
        ctpt2 = NSPoint(x: retPtLocal.x, y: bounds.height * 0.45)
    } else {
        ctpt1 = NSPoint(x: argPtLocal.x, y: bounds.height * 0.45)
        ctpt2 = NSPoint(x: retPtLocal.x, y: bounds.height * 0.55)
    }
}

path.curveToPoint(retPtLocal, controlPoint1: ctpt1, controlPoint2: ctpt2)


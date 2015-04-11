// Playground - noun: a place where people can play

import Foundation
import Cocoa


let p = NSBezierPath()

p.moveToPoint(NSPoint(x: 30, y: 30))
p.curveToPoint(NSPoint(x: 90, y: 90), controlPoint1: NSPoint(x: 65,y: 30), controlPoint2: NSPoint(x: 55, y:90))


// Playground - noun: a place where people can play

import Foundation
import Cocoa


let appBundle = NSBundle.mainBundle()
let toolSetPath = appBundle.pathForResource("3D Primitives", ofType: "toolset")

// read tool list of designated tool set name from NSBundle.
if let path = toolSetPath {
    let toolSetString = String(contentsOfFile: path, encoding:NSUTF8StringEncoding, error: nil)
    
    if let string = toolSetString {
        string.componentsSeparatedByString("\n")
    }
    
}


var a = "test like bug \n Jhon can start test"
var c = a.componentsSeparatedByString("\n")









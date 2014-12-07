// Playground - noun: a place where people can play

import Foundation
import Cocoa
import OpenGL

let bundle = NSBundle.mainBundle()

let b: UnsafePointer<CChar> = "baka".withCString()


let a = String.init(CString: b, encoding: NSUTF8StringEncoding)!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)


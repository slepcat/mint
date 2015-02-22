// Playground - noun: a place where people can play

import Foundation
import Cocoa
import OpenGL

class Tag {
    private var count:Int = 0
    private init() {}
    
    var newTag: Int {
        return count++
    }
    
    class var get: Tag {
        struct Static {
            static let tagFactory = Tag()
        }
        return Static.tagFactory
    }
}

var a = Tag.get.newTag
a = Tag.get.newTag
a = Tag.get.count


var b = Tag()

b.get.newTag
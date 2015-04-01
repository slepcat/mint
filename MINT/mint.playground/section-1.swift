// Playground - noun: a place where people can play

import Foundation
import Cocoa


class LeafID {
    private var count:Int = 0
    private init(){}
    
    var newID: Int {
        return count++
    }
    
    class var get: LeafID {
        struct Static{
            static let idFactory = LeafID()
        }
        return Static.idFactory
    }
}



let ad = LeafID.get.newID

let ac = LeafID.get.newID

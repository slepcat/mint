//
//  MintSingletons.swift
//  MINT
//
//  Created by NemuNeko on 2015/02/22.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation


// tag generator.
// Tag factory: we can request a unique tag through Tag.getTag
// Singleton

class Tag {
    private var count:Int = 0
    private init(){}
    
    var newTag: Int {
        count += 1
        return count
    }
    
    class var get: Tag {
        struct Static{
            static let tagFactory = Tag()
        }
        return Static.tagFactory
    }
}


// leaf id generator.
// leafID factory: we can request a unique ID through leafID.get.newID
// Singleton

class LeafID {
    private var count:Int = 0
    private init(){}
    
    var newID: Int {
        count += 1
        return count
    }
    
    class var get: LeafID {
        struct Static{
            static let idFactory = LeafID()
        }
        return Static.idFactory
    }
}

// leaf born count generator.
// record called leaf type & return count for each type
/*
class BirthCount {
    private var counts:[Int] = []
    private var types:[String] = []
    private init(){}
    
    func count(type: String) -> Int {
        for var i = 0; types.count > i; i += 1 {
            if types[i] == type {
                return counts[i] ++
            }
        }
        
        // in case of no such type in past
        types += [type]
        counts += [1]
        
        return counts.last! - 1
    }
    
    class var get: BirthCount {
        struct Static{
            static let idFactory = BirthCount()
        }
        return Static.idFactory
    }
}
*/
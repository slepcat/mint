//
//  MintSingletons.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/02/22.
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
        return count++
    }
    
    class var get: Tag {
        struct Static{
            static let tagFactory = Tag()
        }
        return Static.tagFactory
    }
}
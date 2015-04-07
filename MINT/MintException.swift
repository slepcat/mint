//
//  MintException.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/09.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

// Mint exception class
// Exception stack for Mint, manage invalid user operation.

enum MintException {
    case None// No error
    case TypeInvalid(leafName: String, leafID: Int, requiredType: String, invalidType:String) // type of variable is invalid
}

class MintErr {
    private var exceptions : [MintException] = []
    private weak var interpreter : MintInterpreter!
    private init(){}
    
    var catch: MintException {
        if let err = exceptions.last {
            exceptions.removeLast()
            return err
        }
        
        return MintException.None
    }
    
    func rise(newErr: MintException) {
        exceptions.append(newErr)
    }
    
    class var stack: MintErr {
        struct Static{
            static let exception = MintErr()
        }
        return Static.exception
    }
    
}
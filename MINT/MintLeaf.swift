//
//  MintLeaf.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/08.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

class Leaf:MintLeaf {
    func eval(arg: Any) -> Any {
        
        // If 'arg' is 'Leaf' instance, call solve() method.
        // If 'arg' is value except 'Leaf', return it as 'Any' type.
        switch arg {
        case let someLeaf as Leaf:
            return someLeaf.solve()
        default:
            return arg
        }
    }
    
    func solve() -> Any {
        return NSNull()
    }
}

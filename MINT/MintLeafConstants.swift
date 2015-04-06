//
//  MintLeafConstants.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/04/06.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

// data container leaves
/// Double constant
class BoolLeaf: Leaf {
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        argLabels = ["bool"]
        argTypes = ["Bool"]
        args = [true]
    }
    
    func reInitArg(label: String) {
        if label == "bool" {
            setArg(label, value: 0.0)
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("bool") as? Bool {
            return result
        }
    
        return nil
    }
}

/// Double constant
class DoubleLeaf: Leaf {
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        argLabels = ["double"]
        argTypes = ["Double"]
        args = [0.0]
    }
    
    func reInitArg(label: String) {
        if label == "double" {
            setArg(label, value: 0.0)
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("double") as? Double {
            return result
        }
        
        return nil
    }
}

/// Int constant
class IntLeaf: Leaf {
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        argLabels = ["int"]
        argTypes = ["Int"]
        args = [0]
    }
    
    func reInitArg(label: String) {
        if label == "int" {
            setArg(label, value: 0)
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("int") as? Int {
            return result
        }
        
        return nil
    }
}

/// String constant
class StringLeaf: Leaf {
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        argLabels = ["string"]
        argTypes = ["String"]
        args = [""]
    }
    
    func reInitArg(label: String) {
        if label == "string" {
            setArg(label, value: "")
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("string") as? String {
            return result
        }
        
        return nil
    }
}

/// Vector Constant
class VectorLeaf: Leaf {
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [Vector(x: 0, y: 0, z: 0)]
        argLabels = ["vector"]
        argTypes = ["Vector"]
    }
    
    func reInitArg(label: String) {
        if label == "vector" {
            setArg(label, value: Vector(x: 0, y: 0, z: 0))
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("vector") as? Vector {
            return result
        }
        
        return nil
    }

}
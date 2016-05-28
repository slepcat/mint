//
//  MintLeafConstants.swift
//  MINT
//
//  Created by NemuNeko on 2015/04/06.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

/*

// data container leaves
/// Double constant
class BoolLeaf: Leaf {
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        argLabels = ["bool"]
        argTypes = ["Bool"]
        args = [true]
        
        returnType = "Bool"
        
        let count = BirthCount.get.count("Bool")
        
        name = "Bool\(count)"
    }
    
    override func initArg(label: String) {
        if label == "bool" {
            setArg(label, value: 0.0)
        } else {
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("bool") as? Bool {
            needUpdate = false
            return result
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
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
        
        returnType = "Double"
        
        let count = BirthCount.get.count("Double")
        
        name = "Double\(count)"
    }
    
    override func initArg(label: String) {
        if label == "double" {
            setArg(label, value: 0.0)
        } else {
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("double") as? Double {
            needUpdate = false
            return result
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
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
        
        returnType = "Int"
        
        let count = BirthCount.get.count("Int")
        
        name = "Int\(count)"
    }
    
    override func initArg(label: String) {
        if label == "int" {
            setArg(label, value: 0)
        } else {
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("int") as? Int {
            needUpdate = false
            return result
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
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
        
        returnType = "String"
        
        let count = BirthCount.get.count("String")
        
        name = "String\(count)"
    }
    
    override func initArg(label: String) {
        if label == "string" {
            setArg(label, value: "")
        } else {
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("string") as? String {
            needUpdate = false
            return result
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
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
        
        returnType = "Vector"
        
        let count = BirthCount.get.count("Vector")
        
        name = "Vector\(count)"
    }
    
    override func initArg(label: String) {
        if label == "vector" {
            setArg(label, value: Vector(x: 0, y: 0, z: 0))
        } else {
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    override func solve() -> Any? {
        if let result = eval("vector") as? Vector {
            needUpdate = false
            return result
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
        return nil
    }

}

*/
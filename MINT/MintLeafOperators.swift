//
//  MintLeafOperators.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/04/26.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

class SetColor : Leaf {
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0)]
        args.append(nil)
        argLabels += ["color", "mesh"]
        argTypes += ["Color", "Mesh"]
        
        returnType = "Mesh"
        
        let count = BirthCount.get.count("SetColor")
        
        name = "SetColor\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        switch label {
        case "color":
            let color = Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0)
            setArg("color", value: color)
        case "mesh":
            setArg("mesh", value: nil)
        default:
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    override func solve() -> Any? {
        if let color = eval("color") as? Color, let mesh = eval("mesh") as? Mesh {
            for var i = 0; mesh.mesh.count > i; i++ {
                for var j = 0; mesh.mesh[i].vertices.count > j; j++ {
                    mesh.mesh[i].vertices[j].color = [color.r, color.g, color.b]
                }
            }
            
            return mesh
        }
        
        return nil
    }
}

// Transform operation of Mesh

// Boolean operation of Mesh
class Union : Leaf {
    
}

class Subtract : Leaf {
    
    var mesh : Mesh? = nil
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [nil, nil]
        argLabels += ["target", "subtract"]
        argTypes += ["Mesh", "Mesh"]
        
        returnType = "Mesh"
        
        let count = BirthCount.get.count("Subtract")
        
        name = "Subtract\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        switch label {
        case "target":
            setArg("target", value: nil)
        case "subtract":
            setArg("target", value: nil)
        default:
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    override func solve() -> Any? {
        
        if mesh != nil && needUpdate == false {
            return mesh
        }
        
        if let err = MintErr.exc.catch {
            MintErr.exc.raise(err)
            
            return nil
        }
        
        if let targetMesh = eval("target") as? Mesh, let subtractMesh = eval("subtract") as? Mesh {
            let a = Node(poly: targetMesh.mesh)
            var b = Node(poly: subtractMesh.mesh)
            
            a.invert()
            a.clipTo(b)
            b.clipTo(a)
            b.invert()
            b.clipTo(a)
            b.invert()
            a.build(b.allPolygons())
            a.invert()
            
            mesh = Mesh(m: a.allPolygons())
            
            needUpdate = false
            
            return mesh
        }
        
        return nil
    }
}
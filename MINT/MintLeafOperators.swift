//
//  MintLeafOperators.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/04/26.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

class SetColor : Leaf, MintLeaf {
    
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
            for var i = 0; argLabels.count > i; i++ {
                if argLabels[i] == "mesh" {
                    args[i] = nil
                    break
                }
            }
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
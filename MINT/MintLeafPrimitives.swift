//
//  MintLeafPrimitives.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/09.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

// Primitive class
// Base class for all primitive solids. For example, cube, sphere, cylinder, and so on.
// This class itself will not be instantiated
class Primitive:Leaf {
    
    var mesh : Mesh?
   
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [Vector(x: 0, y: 0, z: 0)]
        argLabels = ["center"]
        argTypes = ["Vector"]
        
        returnType = "Mesh"
        
        name = "null_mesh"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        if label == "center" {
            setArg("center", value: Vector(x: 0, y: 0, z: 0))
        } else {
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    
}

class Cube:Primitive{
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args += [10.0, 10.0, 10.0]
        argLabels += ["width", "height", "depth"]
        argTypes += ["Double", "Double", "Double"]
        
        let count = BirthCount.get.count("Cube")
        
        name = "Cube\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        if let err = MintErr.exc.catch {
            switch label {
            case "width":
                setArg("width", value:10.0)
            case "height":
                setArg("height", value:10.0)
            case "depth":
                setArg("depth", value:10.0)
            case "all":
                super.initArg("center")
                setArg("width", value:10.0)
                setArg("height", value:10.0)
                setArg("depth", value:10.0)
            default:
                MintErr.exc.raise(err)
            }
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
        
        //type cast args
        if let width = eval("width") as? Double, let height = eval("height") as? Double, let depth = eval("depth") as? Double, let center = eval("center") as? Vector {
            
            let left = -width/2 + center.x
            let right = width/2 + center.x
            let front = -depth/2 + center.z
            let back = depth/2 + center.z
            let bottom = -height/2 + center.y
            let top = height/2 + center.y
            
            var vertices : [Vertex] = []
            
            vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))] //bottom
            vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
            
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))] // front
            vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            
            vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))] //right
            vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
            
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))] // back
            vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
            
            vertices += [Vertex(pos: Vector(x: left, y: back, z: top))] //left
            vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
            
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))] // top
            vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
            
            var poly : [Polygon] = []
            
            for var i = 0; i < vertices.count; i += 3 {
                poly += [Polygon(vertices: [vertices[i], vertices[i + 1], vertices[i + 2]], shared: 0)]
            }
            
            mesh = Mesh(m: poly)
            
            needUpdate = false
            
            return mesh
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
        return nil
    }
}

/*
class Sphere:Primitive{
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args += [5.0, 32]
        argLabels += ["radius", "resolution"]
        argTypes += ["Double", "Int"]
        
        let count = BirthCount.get.count("Sphere")
        
        name = "Sphere\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        if let err = MintErr.exc.catch {
            switch label {
            case "radius":
                setArg("radius", value:5.0)
            default:
                MintErr.exc.raise(err)
            }
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
        
        //type cast args
        if let width = eval("radius") as? Double, let center = eval("center") as? Vector {
            
            let left = -width/2 + center.x
            let right = width/2 + center.x
            let front = -depth/2 + center.z
            let back = depth/2 + center.z
            let bottom = -height/2 + center.y
            let top = height/2 + center.y
            
            var vertices : [Vertex] = []
            
            vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))] //bottom
            vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
            
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))] // front
            vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            
            vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))] //right
            vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
            
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))] // back
            vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
            
            vertices += [Vertex(pos: Vector(x: left, y: back, z: top))] //left
            vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
            
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))] // top
            vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
            vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
            vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
            
            var poly : [Polygon] = []
            
            for var i = 0; i < vertices.count; i += 3 {
                poly += [Polygon(vertices: [vertices[i], vertices[i + 1], vertices[i + 2]], shared: 0)]
            }
            
            mesh = Mesh(m: poly)
            
            needUpdate = false
            
            return mesh
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
        return nil
    }
}

*/
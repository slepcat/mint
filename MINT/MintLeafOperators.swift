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
    
    var mesh : Mesh? = nil
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [nil, nil]
        argLabels += ["target1", "target2"]
        argTypes += ["Mesh", "Mesh"]
        
        returnType = "Mesh"
        
        let count = BirthCount.get.count("Union")
        
        name = "Union\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        switch label {
        case "target1":
            setArg("target1", value: nil)
        case "target2":
            setArg("target2", value: nil)
        default:
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    override func solve() -> Any? {
        
        // Like union, but when we know that the two solids are not intersecting
        // Do not use if you are not completely sure that the solids do not intersect!
        func unionForNonIntersecting(target1: Mesh, target2: Mesh) -> Mesh {
            return Mesh(m: target1.mesh + target2.mesh)
        }
        
        if mesh != nil && needUpdate == false {
            return mesh
        }
        
        if let err = MintErr.exc.catch {
            MintErr.exc.raise(err)
            
            return nil
        }
        
        if let targetMesh = eval("target1") as? Mesh, let targetMesh2 = eval("target2") as? Mesh {
            
            if !targetMesh.mayOverlap(targetMesh2) {
                mesh = unionForNonIntersecting(targetMesh, targetMesh2)
            } else {
                var a = MeshTree(polygons: targetMesh.mesh)
                var b = MeshTree(polygons: targetMesh2.mesh)
                a.clipTo(b, alsoRemovecoplanarFront: false)
                b.clipTo(a, alsoRemovecoplanarFront: false)
                b.invert()
                b.clipTo(a, alsoRemovecoplanarFront: false)
                b.invert()
                
                var newpolygons = a.allPolygons() + b.allPolygons()
                
                //if(retesselate) result = result.reTesselated();
                //if(canonicalize) result = result.canonicalized();
                mesh = Mesh(m: newpolygons)
            }
            
            needUpdate = false
            
            return mesh
        }
        
        return nil
    }
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
            setArg("subtract", value: nil)
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
            
            var a = MeshTree(polygons: targetMesh.mesh)
            var b = MeshTree(polygons: subtractMesh.mesh)
            
            a.invert()
            a.clipTo(b, alsoRemovecoplanarFront: false)
            b.clipTo(a, alsoRemovecoplanarFront: true)
            a.addPolygons(b.allPolygons())
            a.invert()
            
            var result = a.allPolygons()
            //if(retesselate) result = result.reTesselated();
            //if(canonicalize) result = result.canonicalized();
            
            mesh = Mesh(m: result)
            
            needUpdate = false
            
            return mesh
        }

        return nil
    }
}

// Boolean operation of Mesh
class Intersect : Leaf {
    
    var mesh : Mesh? = nil
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [nil, nil]
        argLabels += ["target1", "target2"]
        argTypes += ["Mesh", "Mesh"]
        
        returnType = "Mesh"
        
        let count = BirthCount.get.count("Intersect")
        
        name = "Intersect\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        switch label {
        case "target1":
            setArg("target1", value: nil)
        case "target2":
            setArg("target2", value: nil)
        default:
            MintErr.exc.raise(MintEXC.ArgNotExist(leafName: name, leafID: leafID, reguired: label))
        }
    }
    
    override func solve() -> Any? {
        
        // Like union, but when we know that the two solids are not intersecting
        // Do not use if you are not completely sure that the solids do not intersect!
        func unionForNonIntersecting(target1: Mesh, target2: Mesh) -> Mesh {
            return Mesh(m: target1.mesh + target2.mesh)
        }
        
        if mesh != nil && needUpdate == false {
            return mesh
        }
        
        if let err = MintErr.exc.catch {
            MintErr.exc.raise(err)
            
            return nil
        }
        
        if let targetMesh = eval("target1") as? Mesh, let targetMesh2 = eval("target2") as? Mesh {
            
            var a = MeshTree(polygons: targetMesh.mesh)
            var b = MeshTree(polygons: targetMesh2.mesh)
            
            a.invert()
            b.clipTo(a, alsoRemovecoplanarFront: false)
            b.invert()
            a.clipTo(b, alsoRemovecoplanarFront: false)
            b.clipTo(a, alsoRemovecoplanarFront: false)
            a.addPolygons(b.allPolygons())
            a.invert()
            var newpolygons = a.allPolygons()

            //if(retesselate) result = result.reTesselated();
            //if(canonicalize) result = result.canonicalized();
            mesh = Mesh(m: newpolygons)

            needUpdate = false
            
            return mesh
        }
        
        return nil
    }
}


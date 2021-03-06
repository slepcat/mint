//
//  MintLeafOperators.swift
//  MINT
//
//  Created by NemuNeko on 2015/04/26.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

/*

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

// # Rotate leaf

class Rotate : Leaf {
    
    var mesh : Mesh? = nil
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [nil, 0.0, 0.0, 0.0]
        argLabels += ["mesh", "x_angle", "y_angle", "z_angle"]
        argTypes += ["Mesh", "Double", "Double", "Double"]
        
        returnType = "Mesh"
        
        let count = BirthCount.get.count("Rotate")
        
        name = "Rotate\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        switch label {
        case "mesh":
            setArg("mesh", value: nil)
        case "x_angle":
            setArg("x_angle", value: 0.0)
        case "y_angle":
            setArg("y_angle", value: 0.0)
        case "z_angle":
            setArg("z_angle", value: 0.0)
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
        
        if let original = eval("mesh") as? Mesh, let xangle = eval("x_angle") as? Double, let yangle = eval("y_angle") as? Double,  let zangle = eval("z_angle") as? Double {
            
            let rotatematrix = Matrix4x4.rotationZ(zangle) * Matrix4x4.rotationX(xangle) * Matrix4x4.rotationY(yangle)
            
            var newpolygons : [Polygon] = []
            
            for var i = 0; original.mesh.count > i; i++ {
                var newpolyvex : [Vertex] = []
                
                for var j = 0; original.mesh[i].vertices.count > j; j++ {
                    newpolyvex += [original.mesh[i].vertices[j].transform(rotatematrix)]
                }
                
                var newpoly = Polygon(vertices: newpolyvex)
                newpoly.generateNormal()
                newpolygons.append(newpoly)
            }
            
            
            mesh = Mesh(m: newpolygons)
            
            needUpdate = false
            
            return mesh
        }
        
        return nil
    }
}

class RotateAxis : Leaf {
    
    var mesh : Mesh? = nil
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [nil, Vector(x: 0, y: 0, z: 1), 0.0, Vector(x: 0, y: 0, z: 0)]
        argLabels += ["mesh", "axis", "angle", "center"]
        argTypes += ["Mesh", "Vector", "Double", "Vector"]
        
        returnType = "Mesh"
        
        let count = BirthCount.get.count("RotateAxis")
        
        name = "RotateAxis\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        switch label {
        case "mesh":
            setArg("mesh", value: nil)
        case "axis":
            setArg("axis", value: Vector(x: 0, y: 0, z: 1))
        case "angle":
            setArg("angle", value: 0.0)
        case "center":
            setArg("center", value: Vector(x: 0, y: 0, z: 0))
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
        
        if let original = eval("mesh") as? Mesh, let axis = eval("axis") as? Vector, let angle = eval("angle") as? Double, let center = eval("center") as? Vector  {
            
            let rotatematrix = Matrix4x4.rotation(center, rotationAxis: axis, degrees: angle)
            
            var newpolygons : [Polygon] = []
            
            for var i = 0; original.mesh.count > i; i++ {
                var newpolyvex : [Vertex] = []
                
                for var j = 0; original.mesh[i].vertices.count > j; j++ {
                    newpolyvex += [original.mesh[i].vertices[j].transform(rotatematrix)]
                }
                
                var newpoly = Polygon(vertices: newpolyvex)
                newpoly.generateNormal()
                newpolygons.append(newpoly)
            }
            
            
            mesh = Mesh(m: newpolygons)
            
            needUpdate = false
            
            return mesh
        }
        
        return nil
    }
}

class Translate : Leaf {
    
    var mesh : Mesh? = nil
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [nil, Vector(x: 0, y: 0, z: 0)]
        argLabels += ["mesh", "center"]
        argTypes += ["Mesh", "Vector"]
        
        returnType = "Mesh"
        
        let count = BirthCount.get.count("Translate")
        
        name = "Translate\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        switch label {
        case "mesh":
            setArg("mesh", value: nil)
        case "center":
            setArg("center", value: Vector(x: 0, y: 0, z: 0))
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
        
        if let original = eval("mesh") as? Mesh, let center = eval("center") as? Vector  {
            
            let matrix = Matrix4x4.translation(center)
            
            var newpolygons : [Polygon] = []
            
            for var i = 0; original.mesh.count > i; i++ {
                var newpolyvex : [Vertex] = []
                
                for var j = 0; original.mesh[i].vertices.count > j; j++ {
                    newpolyvex += [original.mesh[i].vertices[j].transform(matrix)]
                }
                
                var newpoly = Polygon(vertices: newpolyvex)
                newpoly.generateNormal()
                newpolygons.append(newpoly)
            }
            
            
            mesh = Mesh(m: newpolygons)
            
            needUpdate = false
            
            return mesh
        }
        
        return nil
    }
}


class Scale : Leaf {
    
    var mesh : Mesh? = nil
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args = [nil, Vector(x: 1.0, y: 1.0, z: 1.0)]
        argLabels += ["mesh", "scale"]
        argTypes += ["Mesh", "Vector"]
        
        returnType = "Mesh"
        
        let count = BirthCount.get.count("Scale")
        
        name = "Scale\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        switch label {
        case "mesh":
            setArg("mesh", value: nil)
        case "scale":
            setArg("scale", value: Vector(x: 1.0, y: 1.0, z: 1.0))
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
        
        if let original = eval("mesh") as? Mesh, let scale = eval("scale") as? Vector {
            
            if scale.x > 0 && scale.y > 0 && scale.z > 0 {
                
                let matrix = Matrix4x4.scaling(scale)
                
                var newpolygons : [Polygon] = []
                
                for var i = 0; original.mesh.count > i; i++ {
                    var newpolyvex : [Vertex] = []
                    
                    for var j = 0; original.mesh[i].vertices.count > j; j++ {
                        newpolyvex += [original.mesh[i].vertices[j].transform(matrix)]
                    }
                    
                    var newpoly = Polygon(vertices: newpolyvex)
                    newpoly.generateNormal()
                    newpolygons.append(newpoly)
                }
                
                
                mesh = Mesh(m: newpolygons)
                
                needUpdate = false
                
                return mesh
            }
        }
        return nil
    }
}

*/

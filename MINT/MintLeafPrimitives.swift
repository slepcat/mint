//
//  MintLeafPrimitives.swift
//  MINT
//
//  Created by NemuNeko on 2015/03/09.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
/*
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
                poly += [Polygon(vertices: [vertices[i], vertices[i + 1], vertices[i + 2]])]
            }
            
            mesh = Mesh(m: poly)
            
            needUpdate = false
            
            return mesh
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
        return nil
    }
}


// Construct a solid sphere
// Solve() implementation came from OpenJSCAD
//
// Parameters:
//   center: center of sphere (default [0,0,0])
//   radius: radius of sphere (default 1), must be a scalar
//   resolution: determines the number of polygons per 360 degree revolution (default 12)
//   axes: (optional) an array with 3 vectors for the x, y and z base vectors
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
        if var radius = eval("radius") as? Double, let center = eval("center") as? Vector, var resolution = eval("resolution") as? Int {
            
            if radius < 0 {
                radius = -radius
            }
            
            if resolution < 4 {
                resolution = 4
            }
            
            
            var xvector = Vector(x: 1, y: 0, z: 0).times(radius)
            var yvector = Vector(x: 0, y: -1, z: 0).times(radius)
            var zvector = Vector(x: 0, y: 0, z: 1).times(radius)
            
            var qresolution = Int(round(Double(resolution / 4)))
            
            var prevcylinderpoint : Vector = Vector(x: 0, y: 0, z: 0)
            
            var polygons : [Polygon] = []
            
            for var slice1 = 0; slice1 <= resolution; slice1++ {
                var angle = M_PI * 2.0 * Double(slice1) / Double(resolution)
                var cylinderpoint = xvector.times(cos(angle)) + yvector.times(sin(angle))
                if slice1 > 0 {
                    // cylinder vertices:
                    var prevcospitch : Double = 0
                    var prevsinpitch : Double = 0
                    
                    for var slice2 = 0; slice2 <= qresolution; slice2++ {
                        
                        var pitch = 0.5 * M_PI * Double(slice2) / Double(qresolution)
                        var cospitch = cos(pitch)
                        var sinpitch = sin(pitch)
                        
                        if(slice2 > 0) {
                            var vertices : [Vertex] = []
                            vertices.append(Vertex(pos: center + (prevcylinderpoint.times(prevcospitch) - zvector.times(prevsinpitch))))
                            vertices.append(Vertex(pos: center + (cylinderpoint.times(prevcospitch) - zvector.times(prevsinpitch))))
                            
                            if slice2 < qresolution {
                                vertices.append(Vertex(pos: center + (cylinderpoint.times(cospitch) - zvector.times(sinpitch))))
                            }
                            
                            vertices.append(Vertex(pos: center + (prevcylinderpoint.times(cospitch) - zvector.times(sinpitch))))
                            polygons.append(Polygon(vertices: vertices))
                            
                            vertices = []
                            
                            vertices.append(Vertex(pos: center + (prevcylinderpoint.times(prevcospitch) + zvector.times(prevsinpitch))))
                            vertices.append(Vertex(pos: center + (cylinderpoint.times(prevcospitch) + zvector.times(prevsinpitch))))
                            
                            if(slice2 < qresolution) {
                                vertices.append(Vertex(pos: center + (cylinderpoint.times(cospitch) + zvector.times(sinpitch))))
                            }
                            
                            vertices.append(Vertex(pos: center + (prevcylinderpoint.times(cospitch) + zvector.times(sinpitch))))
                            polygons.append(Polygon(vertices: vertices.reverse()))
                        }
                        prevcospitch = cospitch
                        prevsinpitch = sinpitch
                    }
                }
                prevcylinderpoint = cylinderpoint
            }
            
            mesh = Mesh(m: polygons)
            
            needUpdate = false
            
            return mesh
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
        return nil
    }
}

// Construct a solid cylinder.
// Solve() implementation came from OpenJSCAD
//
// Parameters:
//   height: height of cylinder
//   radius: radius of cylinder (default 5), must be a scalar
//   resolution: determines the number of polygons per 360 degree revolution (default 12)
class Cylinder:Primitive{
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args += [5.0, 10.0, 32]
        argLabels += ["radius", "height", "resolution"]
        argTypes += ["Double", "Double", "Int"]
        
        let count = BirthCount.get.count("Cylinder")
        
        name = "Cylinder\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        if let err = MintErr.exc.catch {
            switch label {
            case "radius":
                setArg("radius", value:5.0)
            case "height":
                setArg("height", value:10.0)
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
        if var radius = eval("radius") as? Double, var height = eval("height") as? Double, let center = eval("center") as? Vector, var resolution = eval("resolution") as? Int {
            
            // handle minus values
            if height < 0 {
                height = -height
            }
            
            if radius < 0 {
                radius = -radius
            }
            
            if resolution < 4 {
                resolution = 4
            }
            
            var s = Vector(x: 0, y: 0, z: -1).times(height/2) + center
            var e = Vector(x: 0, y: 0, z: 1).times(height/2) + center
            var r = radius
            var rEnd = radius
            var rStart = radius
            
            var slices = resolution
            var ray = e - s
            var axisZ = ray.unit() //, isY = (Math.abs(axisZ.y) > 0.5);
            var axisX = axisZ.randomNonParallelVector().unit()
            
            //  var axisX = new CSG.Vector3D(isY, !isY, 0).cross(axisZ).unit();
            var axisY = axisX.cross(axisZ).unit()
            var start = Vertex(pos: s)
            var end = Vertex(pos: e)
            var polygons : [Polygon] = []
            
            func point(stack : Double, slice : Double, radius : Double) -> Vertex {
                var angle = slice * M_PI * 2
                var out = axisX.times(cos(angle)) + axisY.times(sin(angle))
                var pos = s + ray.times(stack) + out.times(radius)
                return Vertex(pos: pos)
            }
            
            for(var i = 0; i < slices; i++) {
                var t0 = Double(i) / Double(slices)
                var t1 = Double(i + 1) / Double(slices)
                
                //if rEnd == rStart { // current arguments cannot take 'rEnd' & 'rStart'
                    polygons.append(Polygon(vertices: [start, point(0, t0, rEnd), point(0, t1, rEnd)]))
                    polygons.append(Polygon(vertices: [point(0, t1, rEnd), point(0, t0, rEnd), point(1, t0, rEnd), point(1, t1, rEnd)]))
                    polygons.append(Polygon(vertices: [end, point(1, t1, rEnd), point(1, t0, rEnd)]))
                /*} else {
                    if(rStart > 0) {
                        polygons.append(Polygon(vertices: [start, point(0, t0, rStart), point(0, t1, rStart)]))
                        polygons.append(Polygon(vertices: [point(0, t0, rStart), point(1, t0, rEnd), point(0, t1, rStart)]))
                    }
                    if(rEnd > 0) {
                        polygons.append(Polygon(vertices: [end, point(1, t1, rEnd), point(1, t0, rEnd)]))
                        polygons.append(Polygon(vertices: [point(1, t0, rEnd), point(1, t1, rEnd), point(0, t1, rStart)]))
                    }
                }*/
            }
            
            mesh = Mesh(m: polygons)
            
            needUpdate = false
            
            return mesh
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
        return nil
    }
}

/*
// Cylinder Solid
// Derived from Sphere of OpenJSCAD, Inferior mesh quality. use above ver.
class Cylinder:Primitive{
    
    override init(newID: Int) {
        super.init(newID: newID)
        
        args += [5.0, 10.0, 32]
        argLabels += ["radius", "height", "resolution"]
        argTypes += ["Double", "Double", "Int"]
        
        let count = BirthCount.get.count("Cylinder")
        
        name = "Cylinder\(count)"
    }
    
    override func initArg(label: String) {
        super.initArg(label)
        
        if let err = MintErr.exc.catch {
            switch label {
            case "radius":
                setArg("radius", value:5.0)
            case "height":
                setArg("height", value:10.0)
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
        if var radius = eval("radius") as? Double, var height = eval("height") as? Double, let center = eval("center") as? Vector, var resolution = eval("resolution") as? Int {
            
            // handle minus values
            if height < 0 {
                height = -height
            }
            
            if radius < 0 {
                radius = -radius
            }
            
            if resolution < 4 {
                resolution = 4
            }
            
            var xvector = Vector(x: 1, y: 0, z: 0).times(radius)
            var yvector = Vector(x: 0, y: 1, z: 0).times(radius)
            var zvector = Vector(x: 0, y: 0, z: 1).times(height / 2)
            
            var qresolution = Int(round(Double(resolution / 4)))
            
            var prevcylinderpoint : Vector = Vector(x: 0, y: 0, z: 0)
            
            var polygons : [Polygon] = []
            
            for var slice1 = 0; slice1 <= resolution; slice1++ {
                var angle = M_PI * 2.0 * Double(slice1) / Double(resolution)
                var cylinderpoint = xvector.times(cos(angle)) + yvector.times(sin(angle))
                
                if slice1 > 0 {
                    var vertices : [Vertex] = []
                    
                    // construct top
                    vertices.append(Vertex(pos: center + zvector))
                    vertices.append(Vertex(pos: center + prevcylinderpoint + zvector))
                    vertices.append(Vertex(pos: center + cylinderpoint + zvector))
                    polygons.append(Polygon(vertices: vertices))
                    
                    // construct wall
                    vertices.append(Vertex(pos: center + prevcylinderpoint + zvector))
                    vertices.append(Vertex(pos: center + cylinderpoint + zvector))
                    vertices.append(Vertex(pos: center + cylinderpoint - zvector))
                    vertices.append(Vertex(pos: center + prevcylinderpoint - zvector))
                    polygons.append(Polygon(vertices: vertices.reverse()))
                    
                    // construct bottom
                    vertices.append(Vertex(pos: center - zvector))
                    vertices.append(Vertex(pos: center + prevcylinderpoint - zvector))
                    vertices.append(Vertex(pos: center + cylinderpoint - zvector))
                    polygons.append(Polygon(vertices: vertices.reverse()))
                }
                prevcylinderpoint = cylinderpoint
            }
            
            mesh = Mesh(m: polygons)
            
            needUpdate = false
            
            return mesh
        }
        
        MintErr.exc.raise(MintEXC.SolverFailed(leafName: name, leafID: leafID))
        
        return nil
    }
}
*/

*/
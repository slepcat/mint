//
//  mintlisp_3d_primitives.swift
//  mint-lisp
//
//  Created by NemuNeko on 2015/09/13.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation


class MintPort: NSObject {
    func write(data: MintIO, uid: UInt) {}
}

class MintReadPort:NSObject {
    func read(path: String, uid: UInt) -> MintIO {return MintIO()}
}

class MintStdPort {
    private var currentport : MintPort? = nil
    private var stderrport : MintPort? = nil
    private init(){}
    
    var port: MintPort? {
        return currentport
    }
    
    var errport: MintPort? {
        return stderrport
    }
    
    func setPort(newPort:MintPort) {
        currentport = newPort
    }
    
    func setErrPort(newErrPort : MintPort ) {
        stderrport = newErrPort
    }
    
    func errprint(err:String, uid: UInt) {
        if let port = stderrport {
            objc_sync_enter(port)
            port.write(IOErr(err: err, uid: uid), uid: uid)
            objc_sync_exit(port)
        }
    }
    
    class var get: MintStdPort {
        struct Static{
            static let portFactory = MintStdPort()
        }
        return Static.portFactory
    }
}

class Display: Primitive {

    override func mirror_for_thread() -> SExpr {
        return Display(uid: uid)
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        var acc: [Double] = []
        var acc_normal: [Double] = []
        var acc_color: [Float] = []
        var acc_alpha: [Float] = []
        
        for arg in args {
            let polys = delayed_list_of_values(arg)
            
            for poly in polys {
                if let p = poly as? MPolygon {
                    let vertices = p.value.vertices
                    
                    if vertices.count == 3 {
                        for vertex in vertices {
                            acc += [vertex.pos.x, vertex.pos.y, vertex.pos.z]
                            acc_normal += [vertex.normal.x, vertex.normal.y, vertex.normal.z]
                            acc_color += vertex.color
                            acc_alpha += [vertex.alpha]
                        }
                    } else if vertices.count > 3 {
                        // if polygon is not triangle, split it to triangle polygons
                        
                        //if polygon.checkIfConvex() {
                        
                        let triangles = p.value.triangulationConvex()
                        
                        for tri in triangles {
                            for vertex in tri.vertices {
                                acc += [vertex.pos.x, vertex.pos.y, vertex.pos.z]
                                acc_normal += [vertex.normal.x, vertex.normal.y, vertex.normal.z]
                                acc_color += vertex.color
                                acc_alpha += [vertex.alpha]
                            }
                        }
                    }
                    
                } else {
                    print("display take only polygons", terminator: "\n")
                    if let port = MintStdPort.get.currentport {
                        objc_sync_enter(port)
                        
                        port.write(IOMesh(mesh: [], normal: [], color: [], alpha: []), uid: uid)
                        
                        objc_sync_exit(port)
                        
                        port.performSelectorOnMainThread("update", withObject: nil, waitUntilDone: false)
                    }
                    return MNull()
                }
            }
        }
        
        if let port = MintStdPort.get.currentport {
            objc_sync_enter(port)
            port.write(IOMesh(mesh: acc, normal: acc_normal, color: acc_color, alpha: acc_alpha), uid: uid)
            objc_sync_exit(port)
            
            port.performSelectorOnMainThread("update", withObject: nil, waitUntilDone: false)
        }
        
        return MNull()
    }
    
    override var category : String {
        get {return "3D Primitives"}
    }
    
    override func params_str() -> [String] {
        return ["poly."]
    }
    
    override func str(indent: String, level: Int) -> String {
        return "display"
    }
    
    override func _debug_string() -> String {
        return "display"
    }
    
    private func delayed_list_of_values(_opds :SExpr) -> [SExpr] {
        if let atom = _opds as? Atom {
            return [atom]
        } else {
            return tail_delayed_list_of_values(_opds, acc: [])
        }
    }
    
    private func tail_delayed_list_of_values(_opds :SExpr, var acc: [SExpr]) -> [SExpr] {
        if let pair = _opds as? Pair {
            acc.append(pair.car)
            return tail_delayed_list_of_values(pair.cdr, acc: acc)
        } else {
            return acc
        }
    }
}

class Cube: Primitive {
    
    override var category : String {
        get {return "3D Primitives"}
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        if args.count == 4 {
            
            if let width = cast2double(args[0]), let height = cast2double(args[1]), let depth = cast2double(args[2]), let center =  args[3] as? MVector {
                
                let left = -width/2 + center.value.x
                let right = width/2 + center.value.x
                let front = depth/2 + center.value.y
                let back = -depth/2 + center.value.y
                let bottom = -height/2 + center.value.z
                let top = height/2 + center.value.z
                
                var vertices : [Vertex] = []
                
                vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))] //bottom
                vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
                vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
                vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
                vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
                vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
                
                vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))] // front
                vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
                vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
                vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
                vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
                vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
                
                vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))] //right
                vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
                vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
                vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
                vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
                vertices += [Vertex(pos: Vector(x: right, y: front, z: bottom))]
                
                vertices += [Vertex(pos: Vector(x: right, y: back, z: top))] // back
                vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
                vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
                vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
                vertices += [Vertex(pos: Vector(x: right, y: back, z: bottom))]
                vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
                
                vertices += [Vertex(pos: Vector(x: left, y: back, z: top))] //left
                vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
                vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
                vertices += [Vertex(pos: Vector(x: left, y: front, z: bottom))]
                vertices += [Vertex(pos: Vector(x: left, y: back, z: bottom))]
                vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
                
                vertices += [Vertex(pos: Vector(x: right, y: back, z: top))] // top
                vertices += [Vertex(pos: Vector(x: right, y: front, z: top))]
                vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
                vertices += [Vertex(pos: Vector(x: left, y: front, z: top))]
                vertices += [Vertex(pos: Vector(x: left, y: back, z: top))]
                vertices += [Vertex(pos: Vector(x: right, y: back, z: top))]
                
                let poly = Pair()
                var pointer = poly
                
                for var i = 0; (i + 3) < vertices.count; i += 3 {
                    var pl = Polygon(vertices: [vertices[i], vertices[i + 1], vertices[i + 2]])
                    pl.generateNormal()
                    pointer.car = MPolygon(_value: pl)
                    pointer.cdr = Pair()
                    pointer = pointer.cdr as! Pair
                }
                
                let i = vertices.count
                
                pointer.car = MPolygon(_value: Polygon(vertices: [vertices[i - 3], vertices[i - 2], vertices[i - 1]]))
                
                return poly
            }
        }
        
        print("cube take 3 double and 1 vector", terminator: "\n")
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["width", "height", "depth", "center"]
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
    
    override var category : String {
        get {return "3D Primitives"}
    }
    
    override func params_str() -> [String] {
        return ["radius", "center", "resolution"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        if args.count == 3 {
            //type cast args
            if var radius = cast2double(args[0]), let cen = args[1] as? MVector, let res = args[2] as? MInt {
                
                let center = cen.value
                var resolution = res.value
                
                if radius < 0 {
                    radius = -radius
                }
                
                if resolution < 4 {
                    resolution = 4
                }
                
                
                let xvector = Vector(x: 1, y: 0, z: 0).times(radius)
                let yvector = Vector(x: 0, y: -1, z: 0).times(radius)
                let zvector = Vector(x: 0, y: 0, z: 1).times(radius)
                
                let qresolution = Int(round(Double(resolution / 4)))
                
                var prevcylinderpoint : Vector = Vector(x: 0, y: 0, z: 0)
                
                var polygons : [Polygon] = []
                
                for var slice1 = 0; slice1 <= resolution; slice1++ {
                    let angle = M_PI * 2.0 * Double(slice1) / Double(resolution)
                    let cylinderpoint = xvector.times(cos(angle)) + yvector.times(sin(angle))
                    if slice1 > 0 {
                        // cylinder vertices:
                        var prevcospitch : Double = 0
                        var prevsinpitch : Double = 0
                        
                        for var slice2 = 0; slice2 <= qresolution; slice2++ {
                            
                            let pitch = 0.5 * M_PI * Double(slice2) / Double(qresolution)
                            let cospitch = cos(pitch)
                            let sinpitch = sin(pitch)
                            
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
                
                var spoly : [MPolygon] = []
                
                for poly in polygons {
                    spoly.append(MPolygon(_value: poly))
                }
                
                return list_from_array(spoly)
            }
        }
        
        print("sphere take 1 double, 1 vector and 1 int", terminator: "\n")
        return MNull()
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
    
    override var category : String {
        get {return "3D Primitives"}
    }
    
    override func params_str() -> [String] {
        return ["radius", "height", "center", "resolution"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        if args.count == 4 {
            
            //type cast args
            if var radius = cast2double(args[0]), var height = cast2double(args[1]), let cen = args[2] as? MVector, var res = args[3] as? MInt {
                
                let center = cen.value
                var resolution = res.value
                
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
                    let
                    angle = slice * M_PI * 2
                    let out = axisX.times(cos(angle)) + axisY.times(sin(angle))
                    let pos = s + ray.times(stack) + out.times(radius)
                    return Vertex(pos: pos)
                }
                
                for(var i = 0; i < slices; i++) {
                    let t0 = Double(i) / Double(slices)
                    let t1 = Double(i + 1) / Double(slices)
                    
                    //if rEnd == rStart { // current arguments cannot take 'rEnd' & 'rStart'
                    polygons.append(Polygon(vertices: [start, point(0, slice: t0, radius: rEnd), point(0, slice: t1, radius: rEnd)]))
                    polygons.append(Polygon(vertices: [point(0, slice: t1, radius: rEnd), point(0, slice: t0, radius: rEnd), point(1, slice: t0, radius: rEnd), point(1, slice: t1, radius: rEnd)]))
                    polygons.append(Polygon(vertices: [end, point(1, slice: t1, radius: rEnd), point(1, slice: t0, radius: rEnd)]))
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
                
                var spoly : [MPolygon] = []
                
                for poly in polygons {
                    spoly.append(MPolygon(_value: poly))
                }
                
                return list_from_array(spoly)
            }

        }
        
        print("cylinder take 2 double, 1 vector and 1 int", terminator: "\n")
        return MNull()
    }
}


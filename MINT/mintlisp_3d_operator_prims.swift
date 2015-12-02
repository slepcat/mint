//
//  mintlisp_3d_operator_prims.swift
//  mint
//
//  Created by NemuNeko on 2015/11/30.
//  Copyright © 2015年 Taizo A. All rights reserved.
//

import Foundation

class TransformOperator : Primitive {
    override var category : String {
        get {return "3D Transforms"}
    }
}

class SetColor : TransformOperator {
    
    override func params_str() -> [String] {
        return ["color", "mesh"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        if args.count == 2 {
            if let c = args[0] as? MColor, let list = args[1] as? Pair {
                
                let color = c.value
                let polylist = delayed_list_of_values(list)
                
                for poly in polylist {
                    if let p = poly as? MPolygon {
                        for var i = 0; p.value.vertices.count > i; i++ {
                            p.value.vertices[i].color = color
                        }
                    } else {
                        print("set-color only take list of polygon and color")
                        return MNull()
                    }
                }
                
                return list_from_array(polylist)
            }
        }
        
        print("set-color only take list of polygon and color")
        return MNull()
    }
}

// Transform operation of Mesh

// Boolean operation of Mesh
class Union : TransformOperator {
    
    override func params_str() -> [String] {
        return ["ojb1", "obj2"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        // Like union, but when we know that the two solids are not intersecting
        // Do not use if you are not completely sure that the solids do not intersect!
        func unionForNonIntersecting(target1: Mesh, target2: Mesh) -> Mesh {
            return Mesh(m: target1.mesh + target2.mesh)
        }
        
        if args.count == 2 {
            
            if let list1 = args[0] as? Pair, let list2 = args[1] as? Pair {
                
                var p1 : [Polygon] = []
                var p2 : [Polygon] = []
                
                for p in delayed_list_of_values(list1) {
                    if let poly = p as? MPolygon {
                        p1.append(poly.value)
                    } else {
                        print("union only take 2 list of polygon")
                        return MNull()
                    }
                }
                
                for p in delayed_list_of_values(list2) {
                    if let poly = p as? MPolygon {
                        p2.append(poly.value)
                    } else {
                        print("union only take 2 list of polygon")
                        return MNull()
                    }
                }
                
                let targetMesh = Mesh(m: p1)
                let targetMesh2 = Mesh(m: p2)
                var polys : [Polygon] = []
                
                if !targetMesh.mayOverlap(targetMesh2) {
                    polys = unionForNonIntersecting(targetMesh, target2: targetMesh2).mesh
                } else {
                    let a = MeshTree(polygons: targetMesh.mesh)
                    let b = MeshTree(polygons: targetMesh2.mesh)
                    a.clipTo(b, alsoRemovecoplanarFront: false)
                    b.clipTo(a, alsoRemovecoplanarFront: false)
                    b.invert()
                    b.clipTo(a, alsoRemovecoplanarFront: false)
                    b.invert()
                    
                    polys = a.allPolygons() + b.allPolygons()
                    
                    //if(retesselate) result = result.reTesselated();
                    //if(canonicalize) result = result.canonicalized();
                }
                
                var spoly : [MPolygon] = []
                
                for p in polys {
                    spoly.append(MPolygon(_value: p))
                }
                
                return list_from_array(spoly)
            }

        }
        
        print("union only take 2 list of polygon")
        return MNull()
    }
}

class Subtract : TransformOperator {
    
    override func params_str() -> [String] {
        return ["target", "subtract"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        if args.count == 2 {
            
            if let list1 = args[0] as? Pair, let list2 = args[1] as? Pair {
                
                var p1 : [Polygon] = []
                var p2 : [Polygon] = []
                
                for p in delayed_list_of_values(list1) {
                    if let poly = p as? MPolygon {
                        p1.append(poly.value)
                    } else {
                        print("subtract only take 2 list of polygon")
                        return MNull()
                    }
                }
                
                for p in delayed_list_of_values(list2) {
                    if let poly = p as? MPolygon {
                        p2.append(poly.value)
                    } else {
                        print("subtract only take 2 list of polygon")
                        return MNull()
                    }
                }
                
                let targetMesh = Mesh(m: p1)
                let subtractMesh = Mesh(m: p2)
                
                let a = MeshTree(polygons: targetMesh.mesh)
                let b = MeshTree(polygons: subtractMesh.mesh)
                
                a.invert()
                a.clipTo(b, alsoRemovecoplanarFront: false)
                b.clipTo(a, alsoRemovecoplanarFront: true)
                a.addPolygons(b.allPolygons())
                a.invert()
                
                let result = a.allPolygons()
                //if(retesselate) result = result.reTesselated();
                //if(canonicalize) result = result.canonicalized();
                
                var spoly : [MPolygon] = []
                
                for p in result {
                    spoly.append(MPolygon(_value: p))
                }
                
                return list_from_array(spoly)
            }
        }
        
        print("subtract only take 2 list of polygon")
        return MNull()
    }
}

// Boolean operation of Mesh
class Intersect : TransformOperator {
    
    override func params_str() -> [String] {
        return ["ojb1", "obj2"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        if args.count == 2 {
            
            if let list1 = args[0] as? Pair, let list2 = args[1] as? Pair {
                
                var p1 : [Polygon] = []
                var p2 : [Polygon] = []
                
                for p in delayed_list_of_values(list1) {
                    if let poly = p as? MPolygon {
                        p1.append(poly.value)
                    } else {
                        print("intersect only take 2 list of polygon")
                        return MNull()
                    }
                }
                
                for p in delayed_list_of_values(list2) {
                    if let poly = p as? MPolygon {
                        p2.append(poly.value)
                    } else {
                        print("intersect only take 2 list of polygon")
                        return MNull()
                    }
                }
                
                let targetMesh = Mesh(m: p1)
                let targetMesh2 = Mesh(m: p2)
                
                let a = MeshTree(polygons: targetMesh.mesh)
                let b = MeshTree(polygons: targetMesh2.mesh)
                
                a.invert()
                b.clipTo(a, alsoRemovecoplanarFront: false)
                b.invert()
                a.clipTo(b, alsoRemovecoplanarFront: false)
                b.clipTo(a, alsoRemovecoplanarFront: false)
                a.addPolygons(b.allPolygons())
                a.invert()
                let newpolygons = a.allPolygons()
                
                //if(retesselate) result = result.reTesselated();
                //if(canonicalize) result = result.canonicalized();
                
                var spoly : [MPolygon] = []
                
                for p in newpolygons {
                    spoly.append(MPolygon(_value: p))
                }
                
                return list_from_array(spoly)
            }
        }
        
        print("intersect only take 2 list of polygon")
        return MNull()
    }
}

// # Rotate leaf

class Rotate : TransformOperator {
    
    override func params_str() -> [String] {
        return ["mesh", "x-angle", "y-angle", "z-angle"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        if args.count == 4 {
            if let list = args[0] as? Pair, let xangle = cast2double(args[1]), let yangle = cast2double(args[2]),  let zangle = cast2double(args[3]) {
                
                let array = delayed_list_of_values(list)
                var acc : [Polygon] = []
                
                for poly in array {
                    if let p = poly as? MPolygon {
                        acc.append(p.value)
                    } else {
                        print("rotate only take list of polygon and 3 double")
                        return MNull()
                    }
                }
                
                let original = Mesh(m: acc)
                
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
                
                var spoly : [MPolygon] = []
                
                for p in newpolygons {
                    spoly.append(MPolygon(_value: p))
                }
                
                return list_from_array(spoly)
            }
        }

        print("rotate only take list of polygon and 3 double")
        return MNull()
    }
}

class RotateAxis : TransformOperator {
    
    override func params_str() -> [String] {
        return ["mesh", "axis", "angle", "center"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 4 {
            if let list = args[0] as? Pair, let ax = args[1] as? MVector, let angle = cast2double(args[2]), let cen = args[3] as? MVector  {
                
                let array = delayed_list_of_values(list)
                var acc : [Polygon] = []
                
                for poly in array {
                    if let p = poly as? MPolygon {
                        acc.append(p.value)
                    } else {
                        print("rotate-axis only take list of polygon , 2 vector and double")
                        return MNull()
                    }
                }
                
                let original = Mesh(m: acc)
                
                let axis = ax.value
                let center = cen.value
                
                
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
                
                var spoly : [MPolygon] = []
                
                for p in newpolygons {
                    spoly.append(MPolygon(_value: p))
                }
                
                return list_from_array(spoly)
            }
        }
        
        print("rotate-axis only take list of polygon , 2 vector and double")
        return MNull()
    }
}

class Translate : TransformOperator {
    
    override func params_str() -> [String] {
        return ["mesh", "center"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {
        
        if args.count == 2 {
            if let list = args[0] as? Pair, let cen = args[1] as? MVector  {
                
                let array = delayed_list_of_values(list)
                var acc : [Polygon] = []
                
                for poly in array {
                    if let p = poly as? MPolygon {
                        acc.append(p.value)
                    } else {
                        print("translate take 1 list of polygon and 1 vector")
                        return MNull()
                    }
                }
                
                let original = Mesh(m: acc)
                let center = cen.value
                
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
                
                var spoly : [MPolygon] = []
                
                for p in newpolygons {
                    spoly.append(MPolygon(_value: p))
                }
                
                return list_from_array(spoly)
            }

        }
        
        print("translate take 1 list of polygon and 1 vector")
        return MNull()
    }
}


class Scale : TransformOperator {
    
    override func params_str() -> [String] {
        return ["mesh", "scale"]
    }
    
    override func apply(args: [SExpr]) -> SExpr {

        if args.count == 2 {
            if let list = args[0] as? Pair, let sc = args[1] as? MVector  {
                
                let array = delayed_list_of_values(list)
                var acc : [Polygon] = []
                
                for poly in array {
                    if let p = poly as? MPolygon {
                        acc.append(p.value)
                    } else {
                        print("scale take 1 list of polygon and 1 vector")
                        return MNull()
                    }
                }
                
                let original = Mesh(m: acc)
                let scale = sc.value
            
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
                    
                    var spoly : [MPolygon] = []
                    
                    for p in newpolygons {
                        spoly.append(MPolygon(_value: p))
                    }
                    
                    return list_from_array(spoly)
                }

            }
        }
        
        print("scale take 1 list of polygon and 1 vector")
        return MNull()
    }
}

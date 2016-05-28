//
//  MintIOs.swift
//  mint
//
//  Created by NemuNeko on 2015/10/11.
//  Copyright © 2015年 Taizo A. All rights reserved.
//

import Foundation

/*

class Display: Primitive {
    
    let port : Mint3DPort
    
    init(port: Mint3DPort) {
        self.port = port
    }
    
    override func apply(var args: [SExpr]) -> SExpr {
        
        var acc: [Double] = []
        var acc_normal: [Double] = []
        var acc_color: [Float] = []
        var portid = 0
        
        if args.count > 0 {
            if let p = args.removeAtIndex(0) as? MInt {
                portid = p.value
            }
        }
        
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
                            }
                        }
                        
                        //} else {
                        
                        //}
                    }
                    
                } else {
                    print("display take only polygons", terminator: "\n")
                    return MNull()
                }
            }
        }
        
        port.write(IOMesh(mesh: acc, normal: acc_normal, color: acc_color), port: portid)
        
        return MNull()
    }
    
    override var category : String {
        get {return "3D Primitives"}
    }
    
    override func params_str() -> [String] {
        return ["portid", "poly."]
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

*/
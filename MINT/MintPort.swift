//
//  MintPort.swift
//  mint
//
//  Created by NemuNeko on 2015/10/11.
//  Copyright © 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

class Mint3DPort : MintPort, MintSubject {
    
    struct Mesh {
        var vexes: [Float] = []
        var normals: [Float] = []
        var colors: [Float] = []
        var alphas: [Float] = []
    }
    
    struct Lines {
        var vexes: [Float] = []
        var normals: [Float] = []
        var colors: [Float] = []
        var alphas: [Float] = []
    }
    
    var portid : UInt = 0
    var portidlist : [UInt] = []
    var obs : [MintObserver] = []
    var mesh : Mesh? = nil
    var lines : Lines? = nil
    var viewctrl : MintModelViewController? = nil
    
    override func write(data: SExpr, uid: UInt){
        
        portid = uid
        
        var acc: [Double] = []
        var acc_normal: [Double] = []
        var acc_color: [Float] = []
        var acc_alpha: [Float] = []
        
        let args = delayed_list_of_values(data)
        
        for arg in args {
            let elms = delayed_list_of_values(arg)
            
            for elm in elms {
                if let p = elm as? MPolygon {
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
                    
                } /*else if let l = elm as? MLine {
                   // implement line
                }*/
            }
        }
        
        mesh = Mesh(vexes: d2farray(acc), normals: d2farray(acc_normal), colors: acc_color, alphas: acc_alpha)
    }
    
    override func update() {
        for o in obs {
            o.update(self, uid: portid)
        }
        
        viewctrl?.setNeedDisplay()
    }
    
    func mesh_vex() -> [Float] {
        if let m = mesh {
            return m.vexes
        }
        
        return []
    }
    
    func mesh_normal() -> [Float] {
        if let m = mesh {
            return m.normals
        }
        
        return []
    }
    
    func mesh_color() -> [Float] {
        if let m = mesh {
            return m.colors
        }
        
        return []
    }
    
    func mesh_alpha() -> [Float] {
        if let m = mesh {
            return m.alphas
        }
        
        return []
    }
    
    
    func line_vex() -> [Float] {
        if let m = mesh {
            return m.vexes
        }
        
        return []
    }
    
    func line_normal() -> [Float] {
        if let m = mesh {
            return m.normals
        }
        
        return []
    }
    
    func line_color() -> [Float] {
        if let m = mesh {
            return m.colors
        }
        
        return []
    }
    
    func line_alpha() -> [Float] {
        if let m = mesh {
            return m.alphas
        }
        
        return []
    }
    
    func registerObserver(observer: MintObserver) {
        obs.append(observer)
    }
    
    func removeObserver(observer: MintObserver) {
        for i in 0..<obs.count {
            if obs[i] === observer {
                obs.removeAtIndex(i)
                break
            }
        }
    }
    
    override func create_port(uid: UInt) {
        for id in portidlist {
            if id == uid {
                return
            }
        }
        
        if let mesh = viewctrl?.addMesh(uid){
            registerObserver(mesh)
            portidlist.append(uid)
        }
    }
    
    override func remove_port(uid: UInt) {
        for i in 0..<portidlist.count {
            if portidlist[i] == uid {
                
                if let mesh = viewctrl?.removeMesh(portidlist[i]) {
                    removeObserver(mesh)
                }
                
                portidlist.removeAtIndex(i)
            }
            
        }
    }
}

class MintErrPort : MintPort, MintSubject {
    
    var portid : UInt = 0
    var obs : [MintObserver] = []
    var err : String = ""
    
    override func write(data: SExpr, uid: UInt){
        if let errmsg = data as? MStr {
            
            err = errmsg.value
            portid = uid
        }
    }
    
    override func update() {        
        for o in obs {
            o.update(self, uid: portid)
        }
    }
    
    func registerObserver(observer: MintObserver) {
        obs.append(observer)
    }
    
    func removeObserver(observer: MintObserver) {
        for i in 0..<obs.count {
            if obs[i] === observer {
                obs.removeAtIndex(i)
                break
            }
        }
    }
}

class MintImportPort : MintReadPort {
    
    override func read(path: String, uid: UInt) -> SExpr {
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            
            if let url = getLibPath(path, docpath: delegate.workspace.fileurl?.URLByDeletingLastPathComponent?.path) {
                
                let coordinator = NSFileCoordinator(filePresenter: delegate.workspace)
                let error : NSErrorPointer = nil
                var output = ""
                
                coordinator.coordinateReadingItemAtURL(url, options: .WithoutChanges, error: error) { (fileurl: NSURL) in
                    
                    do {
                        output = try NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding) as String
                    } catch {
                        print("fail to open", terminator:"\n")
                        return
                    }
                }
                
                // load mint file. and unwrap "_pos_" expression
                let interpreter = delegate.controller.interpreter
                
                var acc : [SExpr] = []
                
                for exp in interpreter.readfile(output) {
                    if let pair = exp as? Pair {
                        let posunwrap = MintPosUnwrapper(expr: pair)
                        acc.append(posunwrap.unwrapped)
                    } else {
                        acc.append(exp)
                    }
                }
                
                return list_from_array(acc)
            }
        }
        
        return MNull()
    }
    
    private func getLibPath(path: String, docpath: String?) -> NSURL? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            return NSURL(fileURLWithPath: path)
        } else {
            let bundle = NSBundle.mainBundle()
            if let libpath = bundle.pathForResource(path, ofType: "mint") {
                return NSURL(fileURLWithPath: libpath)
            } else if let dirpath = docpath {
                if NSFileManager.defaultManager().fileExistsAtPath(dirpath + path) {
                    return NSURL(fileURLWithPath: dirpath + path)
                }
            }
        }
        return nil
    }
}
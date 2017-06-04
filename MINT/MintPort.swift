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
    
    override func write(_ data: SExpr, uid: UInt){
        
        portid = uid
        
        // accumulator for polygons
        var acc: [Double] = []
        var acc_normal: [Double] = []
        var acc_color: [Float] = []
        var acc_alpha: [Float] = []
        
        // accumulator for lines
        var ln_acc: [Double] = []
        var ln_acc_normal: [Double] = []
        var ln_acc_color: [Float] = []
        var ln_acc_alpha: [Float] = []
        
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
                    
                } else if let l = elm as? MLineSeg {
                    // implement line
                    let ln = l.value
                    ln_acc += [ln.from.pos.x, ln.from.pos.y, ln.from.pos.z,
                                ln.to.pos.x, ln.to.pos.y, ln.to.pos.z]
                    ln_acc_normal += [ln.from.normal.x, ln.from.normal.y, ln.from.normal.z,
                                ln.to.normal.x, ln.to.normal.y, ln.to.normal.z]
                    ln_acc_color += ln.from.color + ln.to.color
                    ln_acc_alpha += [ln.from.alpha, ln.to.alpha]
                }
            }
        }
        
        mesh = Mesh(vexes: d2farray(acc), normals: d2farray(acc_normal), colors: acc_color, alphas: acc_alpha)
        lines = Lines(vexes: d2farray(ln_acc), normals: d2farray(ln_acc_normal), colors: ln_acc_color, alphas: ln_acc_alpha)
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
        if let l = lines {
            return l.vexes
        }
        
        return []
    }
    
    func line_normal() -> [Float] {
        if let l = lines {
            return l.normals
        }
        
        return []
    }
    
    func line_color() -> [Float] {
        if let l = lines {
            return l.colors
        }
        
        return []
    }
    
    func line_alpha() -> [Float] {
        if let l = lines {
            return l.alphas
        }
        
        return []
    }
    
    func registerObserver(_ observer: MintObserver) {
        obs.append(observer)
    }
    
    func removeObserver(_ observer: MintObserver) {
        for i in 0..<obs.count {
            if obs[i] === observer {
                obs.remove(at: i)
                break
            }
        }
    }
    
    override func create_port(_ uid: UInt) {
        
        //if the portid is arleady exist, exit func.
        for id in portidlist {
            if id == uid {
                return
            }
        }
        
        if let _mesh = viewctrl?.addMesh(uid), let _lines = viewctrl?.addLines(uid) {
            registerObserver(_mesh)
            registerObserver(_lines)
            portidlist.append(uid)
        }
    }
    
    override func remove_port(_ uid: UInt) {
        for i in 0..<portidlist.count {
            if portidlist[i] == uid {
                
                if let mesh = viewctrl?.removeMesh(portidlist[i]), let lines = viewctrl?.removeLines(portidlist[i]) {
                    removeObserver(mesh)
                    removeObserver(lines)
                }
                
                portidlist.remove(at: i)
                break
            }
            
        }
    }
}

class MintErrPort : MintPort, MintSubject {
    
    var portid : UInt = 0
    var obs : [MintObserver] = []
    var err : String = ""
    
    override func write(_ data: SExpr, uid: UInt){
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
    
    func registerObserver(_ observer: MintObserver) {
        obs.append(observer)
    }
    
    func removeObserver(_ observer: MintObserver) {
        for i in 0..<obs.count {
            if obs[i] === observer {
                obs.remove(at: i)
                break
            }
        }
    }
}

class MintImportPort : MintReadPort {
    
    override func read(_ path: String, uid: UInt) -> SExpr {
        if let delegate = NSApplication.shared().delegate as? AppDelegate {
            
            if let url = getLibPath(path, docpath: delegate.workspace.fileurl?.deletingLastPathComponent().path) {
                
                let coordinator = NSFileCoordinator(filePresenter: delegate.workspace)
                let error : NSErrorPointer = nil
                var output = ""
                
                coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: error) { (fileurl: URL) in
                    
                    do {
                        output = try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue) as String
                    } catch {
                        print("fail to open", terminator:"\n")
                        return
                    }
                }
                
                // load mint file. and unwrap "_pos_" expression
                let interpreter : MintInterpreter = delegate.controller.interpreter
                
                var acc : [SExpr] = []
                
                for exp in interpreter.readfile(fileContent: output) {
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
    
    private func getLibPath(_ path: String, docpath: String?) -> URL? {
        
        if FileManager.default.fileExists(atPath: path) {
            return URL(fileURLWithPath: path)
        } else {
            let bundle = Bundle.main
            if let libpath = bundle.path(forResource: path, ofType: "mint") {
                return URL(fileURLWithPath: libpath)
            } else if let dirpath = docpath {
                if FileManager.default.fileExists(atPath: dirpath + path) {
                    return URL(fileURLWithPath: dirpath + path)
                }
            }
        }
        return nil
    }
}

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
    
    var portid : UInt = 0
    var portidlist : [UInt] = []
    var obs : [MintObserver] = []
    var data : MintIO? = nil
    var viewctrl : MintModelViewController? = nil
    
    override func write(data: MintIO, uid: UInt){
        
        portid = uid
        
        if let _ = data as? IOMesh {
            
            self.data = data

        }
    }
    
    func update() {
        for o in obs {
            o.update(self, uid: portid)
        }
        
        viewctrl?.setNeedDisplay()
    }
    
    func mesh() -> [Double] {
        if let mesh = data as? IOMesh {
            return mesh.mesh
        }
        
        return []
    }
    
    func normal() -> [Double] {
        if let mesh = data as? IOMesh {
            return mesh.normal
        }
        
        return []
    }
    
    func color() -> [Float] {
        if let mesh = data as? IOMesh {
            return mesh.color
        }
        
        return []
    }
    
    func alpha() -> [Float] {
        if let mesh = data as? IOMesh {
            return mesh.alpha
        }
        
        return []
    }
    
    func registerObserver(observer: MintObserver) {
        obs.append(observer)
    }
    
    func removeObserver(observer: MintObserver) {
        for var i = 0; obs.count > i; i++ {
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
        for var i = 0; portidlist.count > i; i++ {
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
    
    override func write(data: MintIO, uid: UInt){
        if let errobj = data as? IOErr {
            
            err = errobj.err
            portid = errobj.uid_err
        }
    }
    
    func update() {
        for o in obs {
            o.update(self, uid: portid)
        }
    }
    
    func registerObserver(observer: MintObserver) {
        obs.append(observer)
    }
    
    func removeObserver(observer: MintObserver) {
        for var i = 0; obs.count > i; i++ {
            if obs[i] === observer {
                obs.removeAtIndex(i)
                break
            }
        }
    }
}

class MintImportPort : MintReadPort {
    
    override func read(path: String, uid: UInt) -> MintIO {
        if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
            
            if let url = getLibPath(path, docpath: delegate.workspace.fileurl?.URLByDeletingLastPathComponent?.path) {
                
                let coordinator = NSFileCoordinator(filePresenter: delegate.workspace)
                let error : NSErrorPointer = NSErrorPointer()
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
                
                return SExprIO(exps: acc)
            }
        }
        
        return SExprIO(exps: [])
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
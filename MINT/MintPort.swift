//
//  MintPort.swift
//  mint
//
//  Created by NemuNeko on 2015/10/11.
//  Copyright © 2015年 Taizo A. All rights reserved.
//

import Foundation

class Mint3DPort : MintPort, MintSubject {
    
    var portid : Int = -1
    var obs : [MintObserver] = []
    var data : MintIO? = nil
    
    func write(data: MintIO, uid: UInt){
        
        if let _ = data as? IOMesh {
            
            self.data = data

            for o in obs {
                o.update(self, uid: 0)
            }
        }
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

class MintErrPort : MintPort, MintSubject {
    
    var obs : [MintObserver] = []
    var err : String = ""
    
    func write(data: MintIO, uid: UInt){
        if let errobj = data as? IOErr {
            
            err = errobj.err
            
            for o in obs {
                o.update(self, uid: errobj.uid_err)
            }
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
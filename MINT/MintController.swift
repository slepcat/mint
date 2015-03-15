//
//  MintController.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/15.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

class MintController:NSObject {
    @IBOutlet var modelview: MintModelView!
    var mint : MintInterpreter
    
    override init() {
        mint = MintInterpreter()
        super.init()
    }
    
    func testMesh() {
        println("test leaf setup")
        
        var cube = Cube()
        var mesh = GLmesh()
        
        modelview.stack.append(mesh)
        mint.addLeaf(cube)
        
        mint.registerObserver(mesh as MintObserver)
        mint.solve()
    }
}
//
//  MintModelViewController.swift
//  mint
//
//  Created by NemuNeko on 2015/09/29.
//  Copyright © 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

// Controller of Model View (openGL 3D View)
// Responsible for providing GLMesh objects to global stack
class MintModelViewController:NSWindowController {
    @IBOutlet weak var modelview: MintModelView!
    weak var port : Mint3DPort!
    
    
    
    
    // update mesh & redraw
    func setNeedDisplay() {
        modelview.needsDisplay = true
    }
}




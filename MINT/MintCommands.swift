//
//  MintCommands.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

class CreateLeaf:MintCommand {
    var reciver : Leaf?
    
    init(reciver: Leaf) {
        self.reciver = reciver
    }
    
    func excute() {
        
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}
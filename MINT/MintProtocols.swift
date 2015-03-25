//
//  MintProtocols.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/02/22.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

protocol MintObserver:class { // observer must be class type
    func update(subject: MintSubject, index: Int)//tell observer which leaves are updated
}

protocol MintSubject:class {
    //return mesh & attributes of leave determined by the index.
    func solveMesh(index: Int) -> (mesh: [Double], normals: [Double], colors: [Float])

    // Observer register & remove
    func registerObserver(observer: MintObserver)
    func removeObserver(observer: MintObserver)
}

protocol MintLeaf {
    // For evaluation & solver
    func eval(arg: Any) -> Any
    func solve() -> Any
}

protocol MintCommand {
    func excute()
    func undo()
    func redo()
}
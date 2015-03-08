//
//  MintProtocols.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/02/22.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

protocol MintObserver {
    func update(mesh:[Vertex])
}

protocol MintSubject {
    var mesh: [Vertex] {get set}
    var bufferid:Int {get set}
    var updated: Bool {get set}
    func registerObserver(observer: MintObserver)
    func removeObserver(observer: MintObserver)
}

protocol MintLeaf {
    func eval(arg: Any) -> Any
    func solve() -> Any
}
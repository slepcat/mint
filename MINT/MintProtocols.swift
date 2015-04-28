//
//  MintProtocols.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/02/22.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

// Observer Pattern protocol for 'ModelView' and 'MintInterpreter'
// Tell change of 'Leaf' model to 'ModelView' to update 3D model view.
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
    func eval(arg: String) -> Any?
    func solve() -> Any?
}


// Observer Pattern ptrotocol for 'LeafView' and 'MintController'
// Sync arguments values between 'LeafView' and 'leaf'
protocol MintLeafObserver:class {
    var leafID : Int {get set}
    
    func initArgs(argLabels: [String], argTypes:[String], args: [Any?])
    func initReturnValueType(type: String)
    func setUniqueName(name: String)
    func update(argLabel: String, arg: Any?)
}

protocol MintLeafSubject:class{
    func registerObserver(observer: MintLeafObserver)
    func removeObserver(observer: MintLeafObserver)
}

// Observer Pattern protocol for 'LinkView' to update link path
protocol MintLinkObserver:class {
    func update(leafID: Int, pos: NSPoint)
}

protocol MintLinkSubject: class {
    func registerObserver(observer: MintLinkObserver)
    func removeObserver(observer: MintLinkObserver)
}

protocol MintCommand {
    func prepare(workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter)
    func execute()
    func undo()
    func redo()
}
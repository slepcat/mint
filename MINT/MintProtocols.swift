//
//  MintProtocols.swift
//  MINT
//
//  Created by NemuNeko on 2015/02/22.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

// Observer Pattern protocol for 'ModelView' and 'MintInterpreter'
// Tell change of 'Leaf' model to 'ModelView' to update 3D model view.
protocol MintObserver:class { // observer must be class type
    func update(_ subject: MintSubject, uid: UInt)//tell observer which leaves are updated
}

protocol MintSubject:class {
    // Observer register & remove
    func registerObserver(_ observer: MintObserver)
    func removeObserver(_ observer: MintObserver)
}

// Observer Pattern protocol for 'LeafView' and 'MintController'
// Sync arguments values between 'LeafView' and 'leaf'
protocol MintLeafObserver:class {
    var uid : UInt {get set}
    
    func init_opds(_ args: [SExpr], labels:[String])
    func setName(_ name: String)
    func update(_ leafid: UInt, newopds: [SExpr], newuid: UInt, olduid: UInt)
}

protocol MintLeafSubject:class{
    func registerObserver(_ observer: MintLeafObserver)
    func removeObserver(_ observer: MintLeafObserver)
}

// Observer Pattern protocol for 'LinkView' to update link path
protocol MintLinkObserver:class {
    func update(_ leafID: UInt, pos: NSPoint)
}

protocol MintLinkSubject: class {
    func registerObserver(_ observer: MintLinkObserver)
    func removeObserver(_ observer: MintLinkObserver)
}

protocol MintCommand {
    weak var workspace: MintWorkspaceController! {get set}
    weak var modelView: MintModelViewController! {get set}
    weak var interpreter: MintInterpreter! {get set}
    func prepare(_ workspace: MintWorkspaceController, modelView: MintModelViewController, interpreter: MintInterpreter)
    func execute()
    func undo()
    func redo()
}

//
//  AppDelegate.swift
//  MINT
//
//  Created by 安藤 泰造 on 2014/10/15.
//  Copyright (c) 2014年 Taizo A. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    @IBOutlet var modelView: MintModelViewController!
    @IBOutlet var workspace: MintWorkspaceController!
    @IBOutlet var toolbar: MintToolbarController!
    @IBOutlet var controller: MintController!

    // MINT Controller

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // prepare MintInterpreter
        let interpreter = MintInterpreter()
        
        controller.interpreter = interpreter
        workspace.interpreter = interpreter
        
        // prepare references
        modelView.globalStack = controller.interpreter.globalStack
        
        //test()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func test() {
        controller.createTestLeaf()
    }
}


//
//  AppDelegate.swift
//  MINT
//
//  Created by NemuNeko on 2014/10/15.
//  Copyright (c) 2014年 Taizo A. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var leafpanel : MintLeafPanelController!
    //@IBOutlet var modelView: MintModelViewController!
    @IBOutlet var workspace: MintWorkspaceController!
    @IBOutlet var controller: MintController!

    // MINT Controller

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // prepare MintInterpreter
        let interpreter = MintInterpreter()
        
        controller.interpreter = interpreter
        workspace.interpreter = interpreter
        
        //prepare leafpanel
        leafpanel.updateContents(interpreter.defined_exps())
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func test() {
        //controller.createTestLeaf()
    }
}


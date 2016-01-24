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
    @IBOutlet var modelView: MintModelViewController!
    @IBOutlet var workspace: MintWorkspaceController!
    @IBOutlet var controller: MintController!

    // MINT Controller

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // prepare MintInterpreter
        let interpreter = MintInterpreter()
        interpreter.controller = controller
        
        controller.interpreter = interpreter
        workspace.interpreter = interpreter
        
        if let port3d = MintStdPort.get.port as? Mint3DPort {
            port3d.viewctrl = modelView
        }
        
        //prepare leafpanel
        leafpanel.updateContents(interpreter.defined_exps())
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        let command = AppQuit()
        controller.sendCommand(command)
        
        if command.willQuit {
            return .TerminateNow
        } else {
            return .TerminateCancel
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
    }
}


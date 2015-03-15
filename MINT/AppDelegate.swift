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
    @IBOutlet var mintController: MintController!
    
    // MINT Controller

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        println("appFinishLaunch")
        
        test()
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }

    func test() {
        println("startTest")
        mintController.testMesh()
    }
}


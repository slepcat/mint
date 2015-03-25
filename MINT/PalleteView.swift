//
//  PalleteView.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/03/20.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

// Tool Pallete in main window
@objc(MintToolPalleteView) class MintToolPalleteView : NSView {
    @IBOutlet weak var palleteController : MintPalleteController!
    
    
}

/*
// Tool button in pallete or folder
@objc(MintToolView) class MintToolView : NSView {
    
    func prepareContent(toolName: String) -> Bool {
        let appBundle = NSBundle.mainBundle()
        let iconPath:String? = appBundle.pathForResource(toolName, ofType: "tiff")
        
        if let path = iconPath {
            let iconImage = NSImage.init(contentsOfFile: path)
            
            if let icon = iconImage {
                let theLayer = CALayer()
                theLayer.contents = icon
                
                self.wantsLayer = true
                self.layer = theLayer
            }else{
                println("Mint tool view cannot open icon image")
                return false
            }
        }else{
            println("Mint tool view cannot get icon path")
            return false
        }
        return true
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
    }
}
*/


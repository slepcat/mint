//
//  ArgumentCellViews.swift
//  MINT
//
//  Created by NemuNeko on 2015/04/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

/*

class MintArgumentCellView : NSTableCellView, NSTextFieldDelegate, NSDraggingDestination {
    @IBOutlet weak var value1: NSTextField!
    @IBOutlet weak var rmbutton: NSButton!
    
    weak var controller: MintLeafViewController!
    
    override func awakeFromNib() {
        value1.delegate = self
        self.registerForDraggedTypes(["com.mint.mint.returnLeafID"])
    }
    
    // 'MintArgumentButton just show argument list. Drop will be catched by 'MintArgumentCell'
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.Link:
            if controller.isLinkReqAcceptable() {
                return NSDragOperation.Link
            }
        default:
            break
        }
        return NSDragOperation.None
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        if let pboad = sender.draggingPasteboard() {
            let pbitems = pboad.readObjectsForClasses([NSPasteboardItem.self], options: nil)
            
            if let item = pbitems?.last as? NSPasteboardItem {
                // pasteboardItemDataProvider is called when below line excuted.
                // but not reflect to return value. API bug??
                // After excution of the line, returnLeafID become available.
                print(item.stringForType("com.mint.mint.returnLeafID"))
            }
            
            switch sender.draggingSourceOperationMask() {
            case NSDragOperation.Link:
                if let leafIDstr = pboad.stringForType("com.mint.mint.returnLeafID") {
                    let leafID = NSString(string: leafIDstr).intValue
                    if let label = self.textField?.stringValue {
                        controller.acceptLinkFrom(Int(leafID), toArg: label)
                    }
                    return true
                }
            default: //anything else will be failed
                return false
            }
        }
        return false
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        print("value edited at \(self.value1.stringValue)")
        
        if let label = self.textField?.stringValue {
            controller.argument(label, valueShouldEndEditing: control.stringValue)
        }
        
        return true
    }
    
    @IBAction func removeLink(sender: AnyObject) {
        if let label = textField {
            controller.removeLink(label.stringValue)
        }
    }
}
*/
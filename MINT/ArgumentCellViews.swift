//
//  ArgumentCellViews.swift
//  MINT
//
//  Created by NemuNeko on 2015/04/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

class MintOperandCellView : NSTableCellView, NSTextFieldDelegate {
    weak var controller: MintLeafViewController!
    var uid : UInt = 0
    
    override func awakeFromNib() {
        self.textField?.delegate = self
        self.register(forDraggedTypes: ["com.mint.mint.returnLeafID", "com.mint.mint.referenceLeafID"])
    }
    
    // 'MintArgumentButton just show argument list. Drop will be catched by 'MintArgumentCell'
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.link:
            if controller.isLinkReqAcceptable() {
                return NSDragOperation.link
            }
        default:
            break
        }
        return []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        let pboad = sender.draggingPasteboard()
        let pbitems = pboad.readObjects(forClasses: [NSPasteboardItem.self], options: nil)
        
        if let item = pbitems?.last as? NSPasteboardItem {
            // pasteboardItemDataProvider is called when below line excuted.
            // but not reflect to return value. API bug??
            // After excution of the line, returnLeafID become available.
            Swift.print(item.string(forType: "com.mint.mint.returnLeafID") ?? "nil", terminator: "\n")
            Swift.print(item.string(forType: "com.mint.mint.referenceLeafID") ?? "nil", terminator: "\n")
        }
        
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.link:
            if let leafIDstr = pboad.string(forType: "com.mint.mint.returnLeafID") {
                let leafID = NSString(string: leafIDstr).intValue
                controller.acceptLinkFrom(UInt(leafID), toArg: uid)

                return true
            } else if let leafIDstr = pboad.string(forType: "com.mint.mint.referenceLeafID") {
                let leafID = NSString(string: leafIDstr).intValue
                controller.acceptRefFrom(UInt(leafID), toArg: uid)
                
                return true
            }
        default: //anything else will be failed
            return false
        }
        return false
    }
    
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        Swift.print("cell value edited (id: \(uid))", terminator: "\n")
        
        let row = controller.operandList.row(for: self)
        
        if let newvalue = self.textField?.stringValue {
            controller.operand(uid, valueDidEndEditing: newvalue, atRow: row)
        }
        
    }
}

class MintRmOpdCellView : MintOperandCellView {
    @IBOutlet weak var rmbutton : NSButton!
    
    @IBAction func remove(_ sender: AnyObject) {
        controller.remove(uid)
    }
}

//
//  ArgumentCellViews.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/04/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa



class MintArgumentCellView : NSTableCellView, NSTextFieldDelegate {
    @IBOutlet weak var value1: NSTextField!
    @IBOutlet weak var rmbutton: NSButton!
    
    weak var controller: MintLeafViewController!
    
    override func awakeFromNib() {
        value1.delegate = self
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        println("value edited at \(self.value1.stringValue)")
        
        if let label = self.textField?.stringValue {
            controller.argument(label, valueShouldEndEditing: control.stringValue)
        }
        
        return true
    }
    
}

class MintVectorCellView : MintArgumentCellView {
    @IBOutlet weak var value2: NSTextField!
    @IBOutlet weak var value3: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        value2.delegate = self
        value3.delegate = self
    }
    
    override func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        if var label = self.textField?.stringValue {
            
            if control === value1 {
                println("value edited at \(self.value1.stringValue)")
                controller.argument(label + "/x", valueShouldEndEditing: control.stringValue)
            } else if control === value2 {
                controller.argument(label + "/y", valueShouldEndEditing: control.stringValue)
            } else if control === value3 {
                controller.argument(label + "/z", valueShouldEndEditing: control.stringValue)
            }
        }
        
        return true
    }
}

class MintBoolCellView : NSTableCellView, NSMatrixDelegate {
    @IBOutlet weak var value1: NSMatrix!
    @IBOutlet weak var rmbutton: NSButton!
    
    weak var controller: MintLeafViewController!
    
    override func awakeFromNib() {
        value1.delegate = self
    }
    
}

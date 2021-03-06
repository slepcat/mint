//
//  MintLeafPanelController.swift
//  mint
//
//  Created by NemuNeko on 2015/09/23.
//  Copyright © 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

// Provide Tool List [toolName:String], [toolImage:NSImage] for Popover
// Using 'toolSet: String' in 'init()', load '.toolset' text file to determine contents of
// NSPopover Interface
class MintLeafPanelController:NSWindowController, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate {
    @IBOutlet weak var leafList : NSTableView!
    @IBOutlet weak var toolList : NSPopUpButton!
    
    @IBOutlet weak var toggleMenu : NSMenuItem!
    
    var leafDic : [String : [String]] = [:]
    var selectedCate : String = ""
    var toolImages : [String : NSImage] = [:]
    
    @IBAction func changeCategory(_ sender: AnyObject?) {
        if let selected = toolList.selectedItem {
            selectedCate = selected.title
            leafList.reloadData()
        }
    }
    
    @IBAction func togglePanel(_ sender: AnyObject?) {
        if let panel = window {
            
            if panel.isVisible {
                close()
                toggleMenu.title = "Show Leaf Panel"
                
            } else {
                showWindow(sender)
                toggleMenu.title = "Hide Leaf Panel"
            }
        }
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        
        toggleMenu.title = "Show Leaf Panel"
        return true
    }
    
    func updateContents(_ leafDic: [String : [String]]) {
        self.leafDic = leafDic
        selectedCate = leafDic.keys.first!
        
        // set categories to popup button
        
        toolList.removeAllItems()
        toolList.addItems(withTitles: [String](leafDic.keys))
        toolList.selectItem(at: 0)
        
        // set data source and delegate for NSTableView
        leafList.dataSource = self as NSTableViewDataSource
        leafList.delegate = self as NSTableViewDelegate
        
        // set drag operation mask
        leafList.setDraggingSourceOperationMask(NSDragOperation.generic, forLocal: true)
        
        // load icon images
        
        let appBundle = Bundle.main
        
        // load default icon
        let toolIconPath = appBundle.path(forResource: "Cube", ofType: "tiff")
        var defaultIcon : NSImage?
        if let path = toolIconPath {
            defaultIcon = NSImage(contentsOfFile: path)
        }
        
        // load unique icons
        for cate in leafDic {
            
            for name in cate.1 {
                
                // load icon
                let toolIconPath = appBundle.path(forResource: name, ofType: "tiff")
                if let path = toolIconPath {
                    let iconImage = NSImage(contentsOfFile: path)
                    
                    if let image = iconImage {
                        toolImages[name] = image
                    }
                } else {
                    // if there is no icon image for tool name, load default icon
                    if let image = defaultIcon {
                        toolImages[name] = image
                    }
                }
                
            }
        }
        // fin load image
    }

    func numberOfRows(in: NSTableView) -> Int {
        
        if let leaves = leafDic[selectedCate] {
            return leaves.count
        }
        
        return 0
    }
    
    // Provide data for NSTableView
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result: AnyObject? = tableView.make(withIdentifier: "leafCell" , owner: self)
        
        if let toolView = result as? NSTableCellView {
            let name = leafDic[selectedCate]![row]
            toolView.textField?.stringValue = name
            toolView.imageView?.image = toolImages[name]
        }
        
        return result as? NSView
    }
    
    // Provide leaf type (=tool name) to NSPasteboard for dragging operation
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        pboard.clearContents()
        pboard.declareTypes(["leaf", "type"], owner: self)
        if let i = rowIndexes.first {
            if pboard.setString(leafDic[selectedCate]![i], forType:"leaf" ) {
                if pboard.setString(selectedCate, forType: "type") {
                    return true
                }
            }
        }
        return false
    }
}

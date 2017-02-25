//
//  LeafView.swift
//  MINT
//
//  Created by NemuNeko on 2015/04/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa

// View of leaf instance
@objc(LeafView) class LeafView : NSView, NSTextFieldDelegate, MintLinkSubject {
    @IBOutlet weak var controller : MintLeafViewController!
    @IBOutlet weak var nameTag : NSTextField!
    //@IBOutlet weak var errStdOut : NSTextField!
    
    var linkviews : [MintLinkObserver] = []
    
    var boundPath : NSBezierPath? = nil
    var focus : Bool = false
    var dragging : Bool = false
    var color : NSColor = NSColor()
    
    override var acceptsFirstResponder : Bool {
        get {
            return true
        }
    }
    
    // for debugging unexpected repositioning
    /*
    override var frame : NSRect {
        set (newvalue){
            Swift.print("leaf: \(controller.leafName), x: \(newvalue.origin.x), y: \(newvalue.origin.y)")
            super.frame = newvalue
        }
        
        get {
            return super.frame
        }
    }
    */
    
    override func awakeFromNib() {
        //if let delegate = NSApplication.sharedApplication().delegate as? AppDelegate {
        //    controller = delegate.controller
        //}
        
        switch controller.leafType {
        case "Test":
            color = NSColor(calibratedWhite: 0.5, alpha: 1)
        default:
            color = NSColor(calibratedWhite: 0.5, alpha: 1)
        }
        
        // to deter auto repositining when workspace view resized
        autoresizingMask = NSAutoresizingMaskOptions.viewNotSizable
        
        nameTag.delegate = self
        
        boundPath = NSBezierPath(roundedRect: NSRect(x: 31, y: 26, width: 32, height: 32), xRadius: 5.0, yRadius: 5.0)
        boundPath?.lineWidth = 3.0
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let background = boundPath {
            color.set()
            
            background.fill()
            
        }
        
        if focus {
            if let focusRing = boundPath {
                let ringColor = NSColor(calibratedRed: 0.3, green: 1, blue: 0.3, alpha: 1)
                
                ringColor.setStroke()
                focusRing.stroke()
            }
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let pt : NSPoint = convert(theEvent.locationInWindow, from: nil)
        let hit : Bool = isPointInItem(pt)
        
        if hit {
            dragging = true
        }
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        if dragging {
            setNeedsDisplay(frame)
            
            var pos : NSPoint = frame.origin
            pos.x += theEvent.deltaX
            pos.y -= theEvent.deltaY
            
            if pos.x < 0 {
                pos.x = 0
            }
            
            if pos.y < 0 {
                pos.y = 0
            }
            
            setFrameOrigin(pos)
            
            for link in linkviews {
                link.update(controller.uid, pos: frame.origin)
            }
            
            autoscroll(with: theEvent)
            
            setNeedsDisplay(frame)
            
            //controller.leaf_moved()
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        dragging = false
        
        //print("before reshape x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.size.width), height:\(frame.size.height)")

        controller.reshapeWorkspace(frame)
        
        //print("after reshape x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.size.width), height:\(frame.size.height)")
        
        for link in linkviews {
            link.update(controller.uid, pos: frame.origin)
        }
        
    }
    
    func isPointInItem(_ pos: NSPoint) -> Bool {
        if let path = boundPath {
            return path.contains(pos)
        } else {
            return false
        }
    }
    
    // trigger remove by delete keydown
    override func keyDown(with theEvent: NSEvent) {
        
        let keystroke = theEvent.charactersIgnoringModifiers
        
        if let key = keystroke {
            if key.characters.count == 1 {
                let s = key.unicodeScalars
                let v = s[s.startIndex].value
                
                if Int(v) == NSDeleteCharacter {
                    controller.removeSelf()
                    return
                }
            }
        }
        
        super.keyDown(with: theEvent)
    }
    
    // focus ring management
    
    override func becomeFirstResponder() -> Bool {
        focus = true
        
        needsDisplay = true
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        focus = false
        
        needsDisplay = true
        
        return super.resignFirstResponder()
    }
    
    // name edit event handling
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        Swift.print("leaf name edited at \(self.nameTag.stringValue)")
        
        if let name = self.nameTag?.stringValue {
            controller.setName(name)
        }
        
        return true
    }
    
    // link observer pattern implementation
    /// register observer
    
    func registerObserver(_ observer: MintLinkObserver) {
        linkviews.append(observer)
    }
    
    func removeObserver(_ observer: MintLinkObserver) {
        for i in 0..<linkviews.count {
            if linkviews[i] === observer {
                linkviews.remove(at: i)
                break
            }
            
        }
    }
}

// Return value button represent return value of leaf in LeafView
// Accept drag & drop from 'MintOperandCellView'
// Source of drag & drop to 'MintOperandCellView'
class MintReturnButton : NSButton, NSDraggingSource, NSPasteboardItemDataProvider {
    @IBOutlet weak var controller : MintLeafViewController!
    
    // drag from argument
    /// set acceptable drag items
    override func awakeFromNib() {
        self.register(forDraggedTypes: ["argumentID"])
    }
    
    /// Tell valid drag operation type. need to match with op. type of drag source.
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.link:
            return NSDragOperation.link
        default: //anything else
            return []
        }
    }
    
    /// accept drop & tell 'controller' to generate new link
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        let arg = sender.draggingPasteboard()
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.link:
            if let type = arg.string(forType: "type") {
                if type == "argumentLink" {
                    if let argIDstr = arg.string(forType: "argumentID"), let leafIDstr = arg.string(forType: "argLeafID") {
                        let leafID = NSString(string: leafIDstr).integerValue
                        let argID = NSString(string: argIDstr).integerValue
                        
                        if controller.leafName == "define" {
                            //controller.setRefFrom
                        } else {
                            controller.setLinkFrom(UInt(leafID), withArg: UInt(argID))
                        }
                        
                        return true
                    }
                }
            }
        default: //anything else will be failed
            return false
        }
        return false
    }
    
    //  source drag operation to argument
    /// override mousedown()
    override func mouseDown(with theEvent: NSEvent) {
        let pbItem : NSPasteboardItem = NSPasteboardItem()
        
        if controller.leafName == "define" {
            pbItem.setDataProvider(self, forTypes: ["com.mint.mint.referenceLeafID"])
        } else {
            pbItem.setDataProvider(self, forTypes: ["com.mint.mint.returnLeafID"])
        }
        
        let dragItem = NSDraggingItem(pasteboardWriter:pbItem)
        
        let draggingRect = self.bounds
        dragItem.setDraggingFrame(draggingRect, contents: self.image!)
        let draggingSession = self.beginDraggingSession(with: [dragItem], event:theEvent, source:self)
        draggingSession.animatesToStartingPositionsOnCancelOrFail = true
        draggingSession.draggingFormation = NSDraggingFormation.none
    }
    
    // provide pasteboard self 'leafID' and value type 'returnLink'
    func pasteboard(_
        pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: String) {
        if let pb = pasteboard {
            pb.clearContents()
            if controller.leafName == "define" {
                pb.declareTypes(["com.mint.mint.referenceLeafID"], owner: self)
            } else {
                pb.declareTypes(["com.mint.mint.returnLeafID"], owner: self)
            }
            
            switch type {
            case "com.mint.mint.referenceLeafID":
                pb.setString("\(controller.uid)", forType: "com.mint.mint.referenceLeafID")
                item.setString("\(controller.uid)", forType: "com.mint.mint.referenceLeafID")
            case "com.mint.mint.returnLeafID":
                pb.setString("\(controller.uid)", forType: "com.mint.mint.returnLeafID")
                item.setString("\(controller.uid)", forType: "com.mint.mint.returnLeafID")
            default:
                break
            }
        }
    }
    
    /// drag operation type
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        switch context {
        case .withinApplication:
            return NSDragOperation.link
        default:
            return []
        }
    }
}

class MintArgumentButton : NSButton {
    @IBOutlet weak var controller : MintLeafViewController!
    
    // drag from return value
    /// set acceptable drag items
    override func awakeFromNib() {
        self.register(forDraggedTypes: ["com.mint.mint.returnLeafID", "com.mint.mint.referenceLeafID"])
    }
    
    // 'MintArgumentButton just show argument list. Drop will be catched by 'MintArgumentCell'
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.link:
            if controller.isLinkReqAcceptable() {
                
                controller.showOpdsPopover(self)
                return NSDragOperation.link
            }
        default:
            break
        }
        return []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return false
    }
}


class LinkView : NSView, MintLinkObserver {
    
    var argleafID : UInt = 0
    var retleafID : UInt = 0
    
    var linkcounter : Int = 0
    
    var argPoint = NSPoint()
    var retPoint = NSPoint()
    
    var needCalc : Bool = true
    var path : NSBezierPath = NSBezierPath()
    var color : NSColor = NSColor(calibratedRed: 0, green: 0.5, blue: 0.6, alpha: 0.5)
    
    // debugging: unexpected repositioning of leafview
    /*
    override var frame : NSRect {
        set (newvalue){
            print("link between:\(argleafID) and: \(retleafID) x: \(newvalue.origin.x), y: \(newvalue.origin.y)")
            super.frame = newvalue
        }
        
        get {
            return super.frame
        }
    }
    */
    
    override func draw(_ dirtyRect: NSRect) {
        
        if needCalc {
            calcLinkPath()
        }
        
        color.setStroke()
        path.lineWidth = 3.0
        path.stroke()
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    func calcLinkPath() {
        
        path = NSBezierPath()
        
        let argPtLocal = self.convert(argPoint, from:self.superview)
        let retPtLocal = self.convert(retPoint, from:self.superview)
        
        path.move(to: argPtLocal)
        
        let ctpt1 : NSPoint
        let ctpt2 : NSPoint
        
        if argPtLocal.x <= retPtLocal.x {
            ctpt1 = NSPoint(x: bounds.width * 0.55, y: argPtLocal.y)
            ctpt2 = NSPoint(x: bounds.width * 0.45, y: retPtLocal.y)
        } else {
            if argPtLocal.y <= retPtLocal.y {
                ctpt1 = NSPoint(x: argPtLocal.x, y: bounds.height * 0.55)
                ctpt2 = NSPoint(x: retPtLocal.x, y: bounds.height * 0.45)
            } else {
                ctpt1 = NSPoint(x: argPtLocal.x, y: bounds.height * 0.45)
                ctpt2 = NSPoint(x: retPtLocal.x, y: bounds.height * 0.55)
            }
        }
        
        path.curve(to: retPtLocal, controlPoint1: ctpt1, controlPoint2: ctpt2)
        
        needCalc = false
    }
    
    func update(_ leafID: UInt, pos: NSPoint) {
        setNeedsDisplay(frame)
        
        if leafID == argleafID {
            argPoint = NSPoint(x: pos.x + 95, y: pos.y + 42)
        } else if leafID == retleafID {
            retPoint = NSPoint(x: pos.x, y: pos.y + 42)
        }
        
        let origin = NSPoint(x: min(argPoint.x, retPoint.x) - 1.5, y:min(argPoint.y, retPoint.y) - 1.5)
        let size = NSSize(width: max(argPoint.x, retPoint.x) - min(argPoint.x, retPoint.x) + 3, height: max(argPoint.y, retPoint.y) - min(argPoint.y, retPoint.y) + 3)
        
        self.frame = NSRect(origin: origin, size: size)
        
        //print("pos, x: \(pos.x), y: \(pos.y)")
        //print("x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.size.width), height:\(frame.size.height)")
        
        needCalc = true
        
        setNeedsDisplay(frame)
    }
    
    func setRefColor() {
        color = NSColor(calibratedRed: 0.7, green: 0, blue: 0.6, alpha: 0.5)
    }
    
    func setLinkColor() {
        color = NSColor(calibratedRed: 0, green: 0.5, blue: 0.6, alpha: 0.5)
    }
}

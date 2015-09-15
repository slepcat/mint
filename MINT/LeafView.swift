//
//  LeafView.swift
//  MINT
//
//  Created by NemuNeko on 2015/04/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa


// View of lneaf instance
@objc(LeafView) class LeafView : NSView, NSTextFieldDelegate, MintLinkSubject {
    @IBOutlet weak var controller : MintLeafViewController!
    @IBOutlet weak var nameTag : NSTextField!
    
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
            println("leaf: \(controller.leafName), x: \(newvalue.origin.x), y: \(newvalue.origin.y)")
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
        autoresizingMask = NSAutoresizingMaskOptions.ViewNotSizable
        
        nameTag.delegate = self
        
        boundPath = NSBezierPath(roundedRect: NSRect(x: 26, y: 3, width: 32, height: 32), xRadius: 5.0, yRadius: 5.0)
        boundPath?.lineWidth = 3.0
    }
    
    override func drawRect(dirtyRect: NSRect) {
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
    
    override func mouseDown(theEvent: NSEvent) {
        let pt : NSPoint = convertPoint(theEvent.locationInWindow, fromView: nil)
        let hit : Bool = isPointInItem(pt)
        
        if hit {
            dragging = true
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        if dragging {
            setNeedsDisplayInRect(frame)
            
            var pos : NSPoint = frame.origin
            pos.x += theEvent.deltaX
            pos.y -= theEvent.deltaY
            
            setFrameOrigin(pos)
            
            for link in linkviews {
                link.update(controller.leafID, pos: frame.origin)
            }
            
            autoscroll(theEvent)
            
            setNeedsDisplayInRect(frame)
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        dragging = false
        
        //println("before reshape x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.size.width), height:\(frame.size.height)")

        controller.reshapeWorkspace(frame)
        
        //println("after reshape x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.size.width), height:\(frame.size.height)")
        
        for link in linkviews {
            link.update(controller.leafID, pos: frame.origin)
        }
    }
    
    func isPointInItem(pos: NSPoint) -> Bool {
        if let path = boundPath {
            return path.containsPoint(pos)
        } else {
            return false
        }
    }
    
    // trigger remove by delete keydown
    override func keyDown(theEvent: NSEvent) {
        
        let keystroke = theEvent.charactersIgnoringModifiers
        
        if let key = keystroke {
            if count(key.utf16) == 1 {
                let s = key.unicodeScalars
                let v = s[s.startIndex].value
                
                if Int(v) == NSDeleteCharacter {
                    controller.removeSelf()
                    return
                }
            }
        }
        
        super.keyDown(theEvent)
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
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        println("leaf name edited at \(self.nameTag.stringValue)")
        
        if let name = self.nameTag?.stringValue {
            controller.nameChanged(name)
        }
        
        return true
    }
    
    // link observer pattern implementation
    /// register observer
    
    func registerObserver(observer: MintLinkObserver) {
        linkviews.append(observer)
    }
    
    func removeObserver(observer: MintLinkObserver) {
        for var i = 0; linkviews.count > i; i++ {
            if linkviews[i] === observer {
                linkviews.removeAtIndex(i)
                break
            }
        }
    }
}

// Return value button represent return value of leaf in LeafView
// Accept drag & drop from 'MintArgumentCellView'
// Source of drag & drop to 'MintArgumentCellView'
class MintReturnButton : NSButton, NSDraggingDestination, NSDraggingSource, NSPasteboardItemDataProvider {
    @IBOutlet weak var controller : MintLeafViewController!
    
    // drag from argument
    /// set acceptable drag items
    override func awakeFromNib() {
        self.registerForDraggedTypes(["argument"])
    }
    
    /// Tell valid drag operation type. need to match with op. type of drag source.
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.Link:
            return NSDragOperation.Link
        default: //anything else
            return NSDragOperation.None
        }
    }
    
    /// accept drop & tell 'controller' to generate new link
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        let pboad = sender.draggingPasteboard()
        if let arg = pboad {
            switch sender.draggingSourceOperationMask() {
            case NSDragOperation.Link:
                if let type = arg.stringForType("type") {
                    if type == "argumentLink" {
                        if let arglabel = arg.stringForType("argument") {
                            if let leafIDstr = arg.stringForType("sourceLeafID") {
                                let leafID = NSString(string: leafIDstr).intValue
                                
                                controller.setLinkFrom(Int(leafID), withArg: arglabel)
                                
                                return true
                            }
                        }
                    }
                }
            default: //anything else will be failed
                return false
            }
        }
        return false
    }
    
    //  source drag operation to argument
    /// override mousedown()
    override func mouseDown(theEvent: NSEvent) {
        let pbItem : NSPasteboardItem = NSPasteboardItem()
        pbItem.setDataProvider(self, forTypes: ["com.mint.mint.returnLeafID"])
        
        let dragItem = NSDraggingItem(pasteboardWriter:pbItem)
        
        let draggingRect = self.bounds
        dragItem.setDraggingFrame(draggingRect, contents: self.image!)
        let draggingSession = self.beginDraggingSessionWithItems([dragItem], event:theEvent, source:self)
        draggingSession.animatesToStartingPositionsOnCancelOrFail = true
        draggingSession.draggingFormation = NSDraggingFormation.None
    }
    
    // provide pasteboard self 'leafID' and value type 'returnLink'
    func pasteboard(pasteboard: NSPasteboard!, item: NSPasteboardItem!, provideDataForType type: String!) {
        pasteboard.clearContents()
        pasteboard.declareTypes(["com.mint.mint.returnLeafID"], owner: self)
        
        switch type {
        case "com.mint.mint.returnLeafID":
            pasteboard.setString("\(controller.leafID)", forType: "com.mint.mint.returnLeafID")
            item.setString("\(controller.leafID)", forType: "com.mint.mint.returnLeafID")
        default:
            break
        }
    }
    
    /// drag operation type
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        switch context {
        case .WithinApplication:
            return NSDragOperation.Link
        default:
            return NSDragOperation.None
        }
    }
}

class MintArgumentButton : NSButton, NSDraggingDestination {
    @IBOutlet weak var controller : MintLeafViewController!
    
    // drag from return value
    /// set acceptable drag items
    override func awakeFromNib() {
        self.registerForDraggedTypes(["com.mint.mint.returnLeafID"])
    }
    
    // 'MintArgumentButton just show argument list. Drop will be catched by 'MintArgumentCell'
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        
        switch sender.draggingSourceOperationMask() {
        case NSDragOperation.Link:
            if controller.isLinkReqAcceptable() {
                
                controller.showArgPopover(self)
                return NSDragOperation.Link
            }
        default:
            break
        }
        return NSDragOperation.None
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        return false
    }
}


class LinkView : NSView, MintLinkObserver {
    
    var argleafID : Int = -1
    var retleafID : Int = -1
    
    var linkcounter : Int = 0
    
    var argPoint = NSPoint()
    var retPoint = NSPoint()
    
    var needCalc : Bool = true
    var path : NSBezierPath = NSBezierPath()
    var color : NSColor = NSColor(calibratedRed: 0, green: 0.5, blue: 0.6, alpha: 0.6)
    
    // debugging: unexpected repositioning of leafview
    /*
    override var frame : NSRect {
        set (newvalue){
            println("link between:\(argleafID) and: \(retleafID) x: \(newvalue.origin.x), y: \(newvalue.origin.y)")
            super.frame = newvalue
        }
        
        get {
            return super.frame
        }
    }
    */
    
    override func drawRect(dirtyRect: NSRect) {
        
        if needCalc {
            calcLinkPath()
        }
        
        color.setStroke()
        path.lineWidth = 3.0
        path.stroke()
    }
    
    func calcLinkPath() {
        
        path = NSBezierPath()
        
        let argPtLocal = self.convertPoint(argPoint, fromView:self.superview)
        let retPtLocal = self.convertPoint(retPoint, fromView:self.superview)
        
        path.moveToPoint(argPtLocal)
        
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
        
        path.curveToPoint(retPtLocal, controlPoint1: ctpt1, controlPoint2: ctpt2)
        
        needCalc = false
    }
    
    func update(leafID: Int, pos: NSPoint) {
        setNeedsDisplayInRect(frame)
        
        if leafID == argleafID {
            argPoint = NSPoint(x: pos.x + 84, y: pos.y + 19)
        } else if leafID == retleafID {
            retPoint = NSPoint(x: pos.x, y: pos.y + 19)
        }
        
        let origin = NSPoint(x: min(argPoint.x, retPoint.x) - 1.5, y:min(argPoint.y, retPoint.y) - 1.5)
        let size = NSSize(width: max(argPoint.x, retPoint.x) - min(argPoint.x, retPoint.x) + 3, height: max(argPoint.y, retPoint.y) - min(argPoint.y, retPoint.y) + 3)
        
        self.frame = NSRect(origin: origin, size: size)
        
        //println("pos, x: \(pos.x), y: \(pos.y)")
        //println("x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.size.width), height:\(frame.size.height)")
        
        needCalc = true
        
        setNeedsDisplayInRect(frame)
    }
}


//
//  ModelView.swift
//  MINT
//
//  Created by 安藤 泰造 on 2014/10/16.
//  Copyright (c) 2014年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa
import OpenGL

struct ViewPoint {
    var x:GLfloat
    var y:GLfloat
    var z:GLfloat
}

struct ViewAngle {
    var x:GLfloat
    var y:GLfloat
    var z:GLfloat
}

@objc(MintModelView) class MintModelView : NSOpenGLView {
    // Camera coordinate & angle
    var viewPt:ViewPoint = ViewPoint(x: 0,y: -5,z: 180)
    var viewAngle:ViewAngle = ViewAngle(x: -60.0, y: 0.0, z: -45.0)
    let zoomMax:Float = 1000
    let zoomMin:Float = 10
    
    // camera speeds
    
    //var rotateFactor:Float = 0.1
    var zoomFactor:Float = 0.005
    
    // UI Settings
    var drawAxes : Bool = true
    var drawPlane : Bool = true
    var drawLines : Bool = false
    
    var lightingShader:Shader? = nil
    
    // OpenGL Parameters
    let bgColor : [Float] = [0.93, 0.93, 0.93, 1]//Background Color, 7% Gray
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        // Get shader source from NSBundle
        lightingShader = Shader.init(shaderName: "OpenJsCADLightingShader")
        
        if let shader = lightingShader {
            glUseProgram(shader.program)
        } else {
            println("failed to init shader")
        }
        
        glMatrixMode(UInt32(GL_PROJECTION))
        glLoadIdentity()
        
        let aspect = self.frame.size.width / self.frame.size.height
        
        glFrustum(Double(-aspect / (2.0 * 1.79259098692)), Double(aspect / (2.0 * 1.79259098692)), -0.5 / 1.79259098692, 0.5 / 1.79259098692, 0.5, 1000)
        glMatrixMode(UInt32(GL_MODELVIEW))
        
        glClearColor(bgColor[0], bgColor[1], bgColor[2], bgColor[3])
    }
    
    override func drawRect(dirtyRect: NSRect) {
        glClear(UInt32(GL_COLOR_BUFFER_BIT) | UInt32(GL_DEPTH_BUFFER_BIT))
        
        //Set Model View Matrix
        glLoadIdentity()
        glTranslatef(viewPt.x, viewPt.y, -viewPt.z)
        glRotatef(viewAngle.x, 1, 0, 0)
        glRotatef(viewAngle.y, 0, 1, 0)
        glRotatef(viewAngle.z, 0, 0, 1)
        
        self.drawAnObject()
        
        if self.drawAxes || self.drawPlane {
            self.drawAxesAndPlane()
        }
        
        glFlush()
    }
    
    func drawAnObject() {
        glColor3f(1.0, 0.85, 0.35)
        glBegin(UInt32(GL_TRIANGLES))
            glVertex3f(  0.0,  30.0, 0.0)
            glVertex3f( -10.0, -20.0, 0.0)
            glVertex3f(  10.0, -20.0 ,0.0)
        glEnd()
    }
    
    func drawAxesAndPlane() {
        glEnable(UInt32(GL_BLEND))
        glBlendFunc(UInt32(GL_SRC_ALPHA), UInt32(GL_ONE_MINUS_SRC_ALPHA))
        glBegin(UInt32(GL_LINES))
        let plate:Float = 200
        if(self.drawPlane) {
            glColor4f(0.8,0.8,0.8,0.5) // -- minor grid
            for var x = -plate / 2; x <= plate / 2; x += 1 {
                if (x % 10) != 0 {
                    glVertex3f(-plate/2, x, 0)
                    glVertex3f(plate/2, x, 0)
                    glVertex3f(x, -plate/2, 0)
                    glVertex3f(x, plate/2, 0)
                }
            }
            glColor4f(0.5,0.5,0.5,0.5) // -- major grid
            for var x = -plate / 2; x <= plate / 2; x += 10 {
                glVertex3f(-plate/2, x, 0)
                glVertex3f(plate/2, x, 0)
                glVertex3f(x, -plate/2, 0)
                glVertex3f(x, plate/2, 0)
            }
        }
        
        //draw axis
        if self.drawAxes {
            //X - red
            glColor4f(1, 0.5, 0.5, 0.2) //negative direction is lighter
            glVertex3f(-100, 0, 0)
            glVertex3f(0, 0, 0)
            
            glColor4f(1, 0, 0, 0.8) //positive direction
            glVertex3f(0, 0, 0)
            glVertex3f(100, 0, 0)
            //Y - green
            glColor4f(0.5, 1, 0.5, 0.2) //negative direction is lighter
            glVertex3f(0, -100, 0)
            glVertex3f(0, 0, 0)
            
            glColor4f(0, 1, 0, 0.8) //positive direction
            glVertex3f(0, 0, 0)
            glVertex3f(0, 100, 0)
            //Z - black
            glColor4f(0.5, 0.5, 0.5, 0.2) //negative direction is lighter
            glVertex3f(0, 0, -100)
            glVertex3f(0, 0, 0)
            
            glColor4f(0.2, 0.2, 0.2, 0.8) //positive direction
            glVertex3f(0, 0, 0)
            glVertex3f(0, 0, 100)
            
            //arrow? ported from openJsCAD, but seems not useful
            /*
            glBegin(UInt32(GL_TRIANGLES))
            glColor4f(0.6, 0.2, 0.6, 0.2) //positive direction
            glVertex3f(-plate,-plate,0)
            glVertex3f(plate,-plate,0)
            glVertex3f(plate,plate,0)
            glEnd()
            
            glBegin(UInt32(GL_TRIANGLES))
            glColor4f(0.6, 0.2, 0.6, 0.2) //positive direction
            glVertex3f(plate,plate,0)
            glVertex3f(-plate,plate,0)
            glVertex3f(-plate,-plate,0)
            glEnd()
            */
        }
        glEnd()
        glDisable(UInt32(GL_BLEND))
    }
    
    
    // event handling
    // rotate view, zoom in/out, pan
    
    //rotate view when the mouse dragged with left button
    
    override func mouseDown(theEvent: NSEvent) {
        
        //let clickPt: NSPoint = theEvent.locationInWindow
        //lastPt = self.convertPoint(clickPt, fromView: nil)
        //println("mouse down at X:\(lastPt.x), Y:\(lastPt.y)")
    }
    
    override func mouseDragged(theEvent : NSEvent) {
        /*
        let draggedPt:NSPoint = theEvent.locationInWindow
        let currentPt:NSPoint = self.convertPoint(draggedPt, fromView: nil)
        
        let delta:NSPoint = NSPoint(x: currentPt.x - lastPt.x, y: currentPt.y - lastPt.y)
        
        //println("mouse dragged to X:\(lastPt.x), Y:\(lastPt.y)")
        println("delta are X:\(delta.x), Y:\(delta.y)")
        */
        
        if NSEventModifierFlags.AlternateKeyMask & theEvent.modifierFlags != nil {
            //rotate x and y
            //rotateFactor is for speed control. but system delta value work fine
            //and I decided not to adjust it by user preference
            
            viewAngle.y += Float(theEvent.deltaX)// * rotateFactor * 0.5
            viewAngle.x += Float(theEvent.deltaY)// * rotateFactor
        } else {
            //rotate x and z
            
            viewAngle.z += Float(theEvent.deltaX)// * rotateFactor * 0.5
            viewAngle.x += Float(theEvent.deltaY)// * rotateFactor
        }
        
        println("viewAngle.X:\(viewAngle.x),Y:\(viewAngle.y), Z:\(viewAngle.z)")
        
        self.needsDisplay = true
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
        //let upPt:NSPoint = theEvent.locationInWindow
        //lastPt = self.convertPoint(upPt, fromView: nil)
        //println("mouse up at X:\(lastPt.x), Y:\(lastPt.y)")
    }
    
    //pan view when the mouse dragged with right button
    
    override func rightMouseDown(theEvent: NSEvent) {
        
    }
    
    override func rightMouseDragged(theEvent : NSEvent) {
        
    }
    
    override func rightMouseUp(theEvent: NSEvent) {
        
    }
    
    //zoom in/out when mouse wheel scrolled
    
    override func scrollWheel(theEvent: NSEvent) {
        // this code came from openJsCAD:onmousewheel func
        
        let wheelDelta = theEvent.deltaY
        if wheelDelta != 0 {
            let factor = pow(1.003, -wheelDelta)
            var coeff = (self.viewPt.z - self.zoomMin) / (self.zoomMax - self.zoomMin)
            
            // coeff must be 0..1
            if coeff > 1 {
                coeff = 1.0
            } else if coeff < 0 {
                coeff = 0.0
            }
            
            coeff = coeff * Float(factor)
            
            println("Zoom with coeff:\(coeff)")
            
            self.viewPt.z = self.zoomMin + coeff * (self.zoomMax - self.zoomMin)
            
            println("view point changed to: \(viewPt.z)")
            
            self.needsDisplay = true
        }
    }

}
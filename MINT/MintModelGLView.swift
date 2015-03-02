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
    //var zoomFactor:Float = 0.005
    
    // UI Settings: Axes & Plane
    var drawAxes : Bool = true
    var drawPlane : Bool = true
    var drawLines : Bool = false
    var axes_vbo : [GLuint] = []
    var plane_vbo : [GLuint] = []
    var pvcount : GLsizei = 0
    var avcount : GLsizei = 0
    var lightingShader:Shader? = nil
    
    // OpenGL Parameters
    let bgColor : [Float] = [0.93, 0.93, 0.93, 1]//Background Color, 7% Gray
    
    // objects
    //var mesh:[MintClass]? = nil
    var vboid:GLuint = 0
    var vboc:GLuint = 0
    var gl_vertex:GLuint = 0
    var gl_color:GLuint = 0
    var gl_alpha:GLuint = 0
    
    // VBO update flag
    var needVBO : Bool = true
    var glmesh:[GLdouble] = []
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        // Get shader source from NSBundle
        lightingShader = Shader.init(shaderName: "OpenJsCADLightingShader")
        
        if let shader = lightingShader {
            glUseProgram(shader.program)
            
            // Vertex id
            var attribId = glGetAttribLocation(shader.program, "gl_Vertex")
            if  attribId >= 0 {
                self.gl_vertex = numericCast(attribId)
            } else {
                println("failed to get gl_Vertex pos")
            }
            // Color id
            attribId = glGetAttribLocation(shader.program, "vertexColor")
            if  attribId >= 0 {
                self.gl_color = numericCast(attribId)
            } else {
                println("failed to get vertexColor")
            }
            // Alpha id
            attribId = glGetAttribLocation(shader.program, "vertexAlpha")
            if  attribId >= 0 {
                self.gl_alpha = numericCast(attribId)
            } else {
                println("failed to get vertexAlpha")
            }
        } else {
            println("failed to init shader")
        }
        
        glMatrixMode(UInt32(GL_PROJECTION))
        glLoadIdentity()
        
        let aspect = self.frame.size.width / self.frame.size.height
        
        glFrustum(Double(-aspect / (2.0 * 1.79259098692)), Double(aspect / (2.0 * 1.79259098692)), -0.5 / 1.79259098692, 0.5 / 1.79259098692, 0.5, 1500)
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
        
        if self.needVBO == true {
            self.updateVBO()
        }
        
        self.drawAnObject()
        
        if self.drawAxes || self.drawPlane {
            self.drawAxesAndPlane()
        }
        
        glFlush()
    }
    
    func prepareMesh4debug() {

    }
    
    func updateVBO() {
        //test code
        
        let mesh: [Vertex] = [Vertex(pos: Vector(x: 0.0 ,y: 30.0, z: 0.0)), Vertex(pos: Vector(x: -10.0, y: -20.0, z:0.0)), Vertex(pos: Vector(x: 10.0, y: -20.0, z: 0.0))]
        
        for m in mesh {
            self.glmesh += [m.pos.x, m.pos.y, m.pos.z]
        }
        
        glGenBuffers(1, &self.vboid)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vboid)
        glBufferData(GLenum(GL_ARRAY_BUFFER), self.glmesh.count * sizeof(GLdouble), &self.glmesh, GLenum(GL_STATIC_DRAW))
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        
        var mcolor: [GLfloat] = [1.0, 0.85, 0.35, 1.0, 0.85, 0.35, 0.5, 0.85, 0.85]
        
        glGenBuffers(1, &self.vboc)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vboc)
        glBufferData(GLenum(GL_ARRAY_BUFFER), mcolor.count * sizeof(GLfloat), &mcolor, GLenum(GL_STATIC_DRAW))
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        
        self.needVBO = false
        
        /* mint model should be implemented
        if mesh == nil {
            return
        }
        
        for m in self.mesh {
            // check buffer id of mesh. if nil, prepare VBO buffer.
            if self.mesh.bufferid == nil {
            
            } else {
                // check update flag. if true, update VBO buffer.
                if self.mesh.updated == true {
                    
                }
            }
        }*/
    }
    
    func drawAnObject() {
        //glColor3f(1.0, 0.85, 0.35)
        
        glEnableVertexAttribArray(gl_vertex)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vboid)
        glVertexAttribPointer(self.gl_vertex, 3, GLenum(GL_DOUBLE), GLboolean(GL_FALSE), 0, nil)
        
        glEnableVertexAttribArray(gl_color)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vboc)
        glVertexAttribPointer(self.gl_color, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        
        //glDrawElements(GLenum(GL_TRIANGLES), GLsizei(self.glmesh.count), GLenum(GL_UNSIGNED_BYTE), nil)
        
        glDisableVertexAttribArray(gl_vertex)
        glDisableVertexAttribArray(gl_color)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)

    }
    
    func drawAxesAndPlane() {
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        let plate:GLfloat = 200
        
        // draw plane grid if required
        if self.drawPlane {
            if self.plane_vbo.count == 0 {
                var planeLines : [GLfloat] = []
                var planeRGB : [GLfloat] = []
                var planeA : [GLfloat] = []
               // -- minor grid
                for var x = -plate / 2; x <= plate / 2; x += 1 {
                    if (x % 10) != 0 {
                        planeLines += [-plate/2, x, 0.0]
                        planeLines += [plate/2, x, 0.0]
                        planeLines += [x, -plate/2, 0.0]
                        planeLines += [x, plate/2, 0.0]
                        planeRGB +=    [0.9,0.9,0.9,
                                        0.9,0.9,0.9,
                                        0.9,0.9,0.9,
                                        0.9,0.9,0.9]
                        planeA += [0.5,0.5,0.5,0.5]
                   }
                }
                // -- major grid
                for var x = -plate / 2; x <= plate / 2; x += 10 {
                    planeLines += [-plate/2, x, 0.0]
                    planeLines += [plate/2, x, 0.0]
                    planeLines += [x, -plate/2, 0.0]
                    planeLines += [x, plate/2, 0.0]
                    planeRGB +=   [0.7,0.7,0.7,
                                    0.7,0.7,0.7,
                                    0.7,0.7,0.7,
                                    0.7,0.7,0.7]
                    planeA += [0.5,0.5,0.5,0.5]
                }
                
                self.plane_vbo = [0,0,0]
                
                // prepare buffer for grid
                glGenBuffers(3, &self.plane_vbo)
                
                // set grid line vertices to 1st buffer
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.plane_vbo[0])
                glBufferData(GLenum(GL_ARRAY_BUFFER), planeLines.count * sizeof(GLfloat), &planeLines, GLenum(GL_STATIC_DRAW))
                // set grid colors to 2nd buffer
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.plane_vbo[1])
                glBufferData(GLenum(GL_ARRAY_BUFFER), planeRGB.count * sizeof(GLfloat), &planeRGB, GLenum(GL_STATIC_DRAW))
                // set grid alpha to 3rd buffer
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.plane_vbo[2])
                glBufferData(GLenum(GL_ARRAY_BUFFER), planeA.count * sizeof(GLfloat), &planeA, GLenum(GL_STATIC_DRAW))
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
                
                self.pvcount = GLsizei(planeA.count)
            }
            
            //println("try to draw gird")
            // draw grid
            glEnableVertexAttribArray(gl_vertex)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.plane_vbo[0])
            glVertexAttribPointer(self.gl_vertex, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glEnableVertexAttribArray(gl_color)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.plane_vbo[1])
            glVertexAttribPointer(self.gl_color, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            
            glEnableVertexAttribArray(gl_alpha)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.plane_vbo[2])
            glVertexAttribPointer(self.gl_alpha, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glDrawArrays(GLenum(GL_LINES), 0, self.pvcount)
            
            
            //glDrawElements(GLenum(GL_TRIANGLES), GLsizei(self.glmesh.count), GLenum(GL_UNSIGNED_BYTE), nil)
            
            glDisableVertexAttribArray(gl_vertex)
            glDisableVertexAttribArray(gl_color)
            glDisableVertexAttribArray(gl_alpha)
           
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        }
        
        // draw axes if required
        if self.drawAxes {
            if self.axes_vbo.count == 0 {
                var axesLines : [GLfloat] = []
                var axesRGB : [GLfloat] = []
                var axesA : [GLfloat] = []
                //X - red
                axesRGB += [1, 0.5, 0.5]
                axesRGB += [1, 0.25, 0.25]
                axesA += [0.0, 0.5] //negative direction is lighter
                axesLines += [-100, 0.0, 0.0]
                axesLines += [0.0, 0.0, 0.0]
                
                axesRGB += [1, 0.25, 0.25]
                axesRGB += [1, 0, 0]
                axesA += [0.5, 1] //positive direction
                axesLines += [0.0, 0.0, 0.0]
                axesLines += [100, 0.0, 0.0]
                //Y - green
                axesRGB += [0.5, 1, 0.5]
                axesRGB += [0.25, 1, 0.25]
                axesA += [0.0, 0.5] //negative direction is lighter
                axesLines += [0.0, -100, 0.0]
                axesLines += [0.0, 0.0, 0.0]
                
                axesRGB += [0.25, 1, 0.25]
                axesRGB += [0, 1, 0]
                axesA += [0.5, 1] //positive direction
                axesLines += [0.0, 0.0, 0.0]
                axesLines += [0.0, 100, 0.0]
                //Z - black
                axesRGB += [0.5, 0.5, 0.5]
                axesRGB += [0.35, 0.35, 0.35]
                axesA += [0.2, 0.6] //negative direction is lighter
                axesLines += [0.0, 0.0, -100]
                axesLines += [0.0, 0.0, 0.0]
                
                axesRGB += [0.35, 0.35, 0.35]
                axesRGB += [0.2, 0.2, 0.2]
                axesA += [0.6, 0.8] //positive direction
                axesLines += [0.0, 0.0, 0.0]
                axesLines += [0.0, 0.0, 100]
                
                self.axes_vbo = [0,0,0]
                
                // prepare buffer for grid
                glGenBuffers(3, &self.axes_vbo)
                
                // set grid line vertices to 1st buffer
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.axes_vbo[0])
                glBufferData(GLenum(GL_ARRAY_BUFFER), axesLines.count * sizeof(GLfloat), &axesLines, GLenum(GL_STATIC_DRAW))
                // set grid colors to 2nd buffer
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.axes_vbo[1])
                glBufferData(GLenum(GL_ARRAY_BUFFER), axesRGB.count * sizeof(GLfloat), &axesRGB, GLenum(GL_STATIC_DRAW))
                // set grid alpha to 3rd buffer
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.axes_vbo[2])
                glBufferData(GLenum(GL_ARRAY_BUFFER), axesA.count * sizeof(GLfloat), &axesA, GLenum(GL_STATIC_DRAW))
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
                
                //self.avcount = GLsizei(axesA.count)
            }
            
            println("try to draw axis")
            // draw grid
            glEnableVertexAttribArray(gl_vertex)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.axes_vbo[0])
            glVertexAttribPointer(self.gl_vertex, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glEnableVertexAttribArray(gl_color)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.axes_vbo[1])
            glVertexAttribPointer(self.gl_color, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            
            glEnableVertexAttribArray(gl_alpha)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.axes_vbo[2])
            glVertexAttribPointer(self.gl_alpha, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glDrawArrays(GLenum(GL_LINES), 0, 12)
            
            glDisableVertexAttribArray(gl_vertex)
            glDisableVertexAttribArray(gl_color)
            glDisableVertexAttribArray(gl_alpha)
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        }
        glDisable(GLenum(GL_BLEND))
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
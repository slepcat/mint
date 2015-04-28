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
    
    // UI Settings: Axes & Plane
    var drawAxes : Bool = true
    var drawPlane : Bool = true
    var axes : Axes? = nil
    var plane : GridPlane? = nil
    
    var lightingShader:Shader? = nil
    
    // OpenGL Parameters
    let bgColor : [Float] = [0.93, 0.93, 0.93, 1]//Background Color, 7% Gray
    
    // Main stack of drawing objects.
    var stack:[GLmesh] = []
    
    //Attribute pointer for shader
    var gl_vertex:GLuint = 0
    var gl_normal:GLuint = 0
    var gl_color:GLuint = 0
    var gl_alpha:GLuint = 0
   
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
            // Normal id
            attribId = glGetAttribLocation(shader.program, "vertexNormal")
            if  attribId >= 0 {
                self.gl_normal = numericCast(attribId)
            } else {
                println("failed to get gl_Normal")
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
        
        glEnable(GLenum(GL_DEPTH_TEST))
        glDepthFunc(GLenum(GL_LESS))
        
        println("open gl view prepared")
    }
    
    override func drawRect(dirtyRect: NSRect) {
        glClear(UInt32(GL_COLOR_BUFFER_BIT) | UInt32(GL_DEPTH_BUFFER_BIT))
        
        //Set Model View Matrix
        glLoadIdentity()
        glTranslatef(viewPt.x, viewPt.y, -viewPt.z)
        glRotatef(viewAngle.x, 1, 0, 0)
        glRotatef(viewAngle.y, 0, 1, 0)
        glRotatef(viewAngle.z, 0, 0, 1)
        
        self.drawObjects()
        
        
        if self.drawAxes {
           drawAxisLines()
        }
        
        if self.drawPlane {
            drawGridPlane()
        }
        
        glFlush()
    }
    
    // draw mesh from stack
    func drawObjects() {
        
        for mesh in stack {
            glEnableVertexAttribArray(gl_vertex)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), mesh.vbufferid)
            glVertexAttribPointer(self.gl_vertex, 3, GLenum(GL_DOUBLE), GLboolean(GL_FALSE), 0, nil)
            
            glEnableVertexAttribArray(gl_color)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), mesh.cbufferid)
            glVertexAttribPointer(self.gl_color, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glEnableVertexAttribArray(gl_normal)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), mesh.nbufferid)
            glVertexAttribPointer(self.gl_normal, 3, GLenum(GL_DOUBLE), GLboolean(GL_FALSE), 0, nil)
            
            glDrawArrays(GLenum(GL_TRIANGLES), 0, mesh.buffersize)
        }
        
        glDisableVertexAttribArray(gl_vertex)
        glDisableVertexAttribArray(gl_color)
        glDisableVertexAttribArray(gl_normal)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    func drawAxisLines() {
        
        if axes == nil {
            axes = Axes()
        }
        
        if let ax = axes {
            glEnable(GLenum(GL_BLEND))
            glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
            
            // draw axes
            glEnableVertexAttribArray(gl_vertex)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), ax.axes_vbo[0])
            glVertexAttribPointer(self.gl_vertex, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glEnableVertexAttribArray(gl_color)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), ax.axes_vbo[1])
            glVertexAttribPointer(self.gl_color, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            
            glEnableVertexAttribArray(gl_alpha)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), ax.axes_vbo[2])
            glVertexAttribPointer(self.gl_alpha, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glEnableVertexAttribArray(gl_normal)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), ax.axes_vbo[3])
            glVertexAttribPointer(self.gl_normal, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glDrawArrays(GLenum(GL_LINES), 0, ax.avcount)
            
            glDisableVertexAttribArray(gl_vertex)
            glDisableVertexAttribArray(gl_color)
            glDisableVertexAttribArray(gl_alpha)
            glDisableVertexAttribArray(gl_normal)
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
            
            glDisable(GLenum(GL_BLEND))

        }
    }
    
    func drawGridPlane() {
        
        if plane == nil {
            plane = GridPlane()
        }
        
        if let pl = plane {
            glEnable(GLenum(GL_BLEND))
            glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
            
            //println("try to draw gird")
            // draw grid
            glEnableVertexAttribArray(gl_vertex)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), pl.plane_vbo[0])
            glVertexAttribPointer(self.gl_vertex, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glEnableVertexAttribArray(gl_color)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), pl.plane_vbo[1])
            glVertexAttribPointer(self.gl_color, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glEnableVertexAttribArray(gl_alpha)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), pl.plane_vbo[2])
            glVertexAttribPointer(self.gl_alpha, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glEnableVertexAttribArray(gl_normal)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), pl.plane_vbo[3])
            glVertexAttribPointer(self.gl_normal, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            
            glDrawArrays(GLenum(GL_LINES), 0, pl.pvcount)
            
            
            //glDrawElements(GLenum(GL_TRIANGLES), GLsizei(self.glmesh.count), GLenum(GL_UNSIGNED_BYTE), nil)
            
            glDisableVertexAttribArray(gl_vertex)
            glDisableVertexAttribArray(gl_color)
            glDisableVertexAttribArray(gl_alpha)
            glDisableVertexAttribArray(gl_normal)
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
            
            glDisable(GLenum(GL_BLEND))
            
        }
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
        
        //println("viewAngle.X:\(viewAngle.x),Y:\(viewAngle.y), Z:\(viewAngle.z)")
        
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
            
            //println("Zoom with coeff:\(coeff)")
            
            self.viewPt.z = self.zoomMin + coeff * (self.zoomMax - self.zoomMin)
            
            //println("view point changed to: \(viewPt.z)")
            
            self.needsDisplay = true
        }
    }

}

class GLmesh:MintObserver {
    // ID of leaf which is counterpart of GLmesh instance
    let leafID : Int
    
    //open gl buffer ids
    var vbufferid : GLuint = 0
    var nbufferid : GLuint = 0
    var cbufferid : GLuint = 0
    //length of mesh array
    var buffersize : GLsizei = 0
    
    init(leafID: Int) {
        self.leafID = leafID
    }
    
    deinit {
        if vbufferid != 0 {
            glDeleteBuffers(1, &vbufferid)
        }
        if nbufferid != 0 {
            glDeleteBuffers(1, &nbufferid)
        }
        if cbufferid != 0 {
            glDeleteBuffers(1, &cbufferid)
        }
    }
    
    // update open gl vertices & attribute array
    func update(subject: MintSubject, index: Int) {
        if vbufferid == 0 { // In case of inital update
            let result = subject.solveMesh(index)
            var glmesh = [GLdouble](result.mesh)
            var glnormal = [GLdouble](result.normals)
            var glcolor = [GLfloat](result.colors)
            
            buffersize = GLsizei(glmesh.count)
            
            if buffersize != 0 {// Check 'result' have valid mesh
                //mesh
                glGenBuffers(1, &self.vbufferid)
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbufferid)
                glBufferData(GLenum(GL_ARRAY_BUFFER), glmesh.count * sizeof(GLdouble), &glmesh, GLenum(GL_STATIC_DRAW))
                //normal
                glGenBuffers(1, &self.nbufferid)
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.nbufferid)
                glBufferData(GLenum(GL_ARRAY_BUFFER), glnormal.count * sizeof(GLdouble), &glnormal, GLenum(GL_STATIC_DRAW))
                //color
                glGenBuffers(1, &self.cbufferid)
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.cbufferid)
                glBufferData(GLenum(GL_ARRAY_BUFFER), glcolor.count * sizeof(GLfloat), &glcolor, GLenum(GL_STATIC_DRAW))
                
                glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
            }
        } else { // In case of update
            let result = subject.solveMesh(index)
            var glmesh = [GLdouble](result.mesh)
            var glnormal = [GLdouble](result.normals)
            var glcolor = [GLfloat](result.colors)
            
            buffersize = GLsizei(glmesh.count)
            
            //mesh
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vbufferid)
            glBufferData(GLenum(GL_ARRAY_BUFFER), glmesh.count * sizeof(GLdouble), &glmesh, GLenum(GL_STATIC_DRAW))
            //normal
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.nbufferid)
            glBufferData(GLenum(GL_ARRAY_BUFFER), glnormal.count * sizeof(GLdouble), &glnormal, GLenum(GL_STATIC_DRAW))
            //color
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.cbufferid)
            glBufferData(GLenum(GL_ARRAY_BUFFER), glcolor.count * sizeof(GLfloat), &glcolor, GLenum(GL_STATIC_DRAW))
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        }
    }
}

class Axes {
    var axes_vbo : [GLuint] = []
    var avcount : GLsizei = 0
    
    init() {
        // draw axes if required
        if self.axes_vbo.count == 0 {
            var axesLines : [GLfloat] = []
            var axesRGB : [GLfloat] = []
            var axesA : [GLfloat] = []
            var axesN : [GLfloat] = []
            
            //X - red
            axesRGB += [1, 0, 0, 1, 0, 0]
            axesA += [0.2, 0.5] //negative direction is lighter
            axesLines += [-100, 0.0, 0.0]
            axesLines += [0.0, 0.0, 0.0]
            axesN += [0.0, 0.0, 1.0, 0.0, 0.0, 1.0]
            
            axesRGB += [1, 0, 0, 1, 0, 0]
            axesA += [0.5, 0.95] //positive direction
            axesLines += [0.0, 0.0, 0.0]
            axesLines += [100, 0.0, 0.0]
            axesN += [0.0, 0.0, 1.0, 0.0, 0.0, 1.0]
            
            //Y - green
            axesRGB += [0, 1, 0, 0, 1, 0]
            axesA += [0.2, 0.5] //negative direction is lighter
            axesLines += [0.0, -100, 0.0]
            axesLines += [0.0, 0.0, 0.0]
            axesN += [0.0, 0.0, 1.0, 0.0, 0.0, 1.0]
            
            axesRGB += [0, 1, 0, 0, 1, 0]
            axesA += [0.5, 0.95] //positive direction
            axesLines += [0.0, 0.0, 0.0]
            axesLines += [0.0, 100, 0.0]
            axesN += [0.0, 0.0, 1.0, 0.0, 0.0, 1.0]
            
            //Z - black
            axesRGB += [0, 0, 0, 0, 0, 0]
            axesA += [0.2, 0.5] //negative direction is lighter
            axesLines += [0.0, 0.0, -100]
            axesLines += [0.0, 0.0, 0.0]
            axesN += [0.0, 0.0, 1.0, 0.0, 0.0, 1.0]
            
            axesRGB += [0, 0, 0, 0, 0, 0]
            axesA += [0.5, 0.95] //positive direction
            axesLines += [0.0, 0.0, 0.0]
            axesLines += [0.0, 0.0, 100]
            axesN += [0.0, 0.0, 1.0, 0.0, 0.0, 1.0]
            
            self.axes_vbo = [0,0,0,0]
            
            self.avcount = GLsizei(axesA.count)
            
            // prepare buffer for grid
            glGenBuffers(4, &self.axes_vbo)
            
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
            // set grid normal to 4th buffer
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.axes_vbo[3])
            glBufferData(GLenum(GL_ARRAY_BUFFER), axesN.count * sizeof(GLfloat), &axesN, GLenum(GL_STATIC_DRAW))
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        }
    }
}

class GridPlane {
    // UI Settings: Axes & Plane
    var plane_vbo : [GLuint] = []
    var pvcount : GLsizei = 0
    
    init() {
        let plate:GLfloat = 200
        
        if self.plane_vbo.count == 0 {
            var planeLines : [GLfloat] = []
            var planeRGB : [GLfloat] = []
            var planeA : [GLfloat] = []
            var planeN : [GLfloat] = []//normal
            // -- minor grid
            for var x = -plate / 2; x <= plate / 2; x += 1 {
                if (x % 10) != 0 {
                    planeLines += [-plate/2, x, 0.0]
                    planeLines += [plate/2, x, 0.0]
                    planeLines += [x, -plate/2, 0.0]
                    planeLines += [x, plate/2, 0.0]
                    planeRGB += [0.9,0.9,0.9,
                        0.9,0.9,0.9,
                        0.9,0.9,0.9,
                        0.9,0.9,0.9]
                    planeN += [0,0,1,
                        0,0,1,
                        0,0,1,
                        0,0,1]
                    planeA += [0.5,0.5,0.5,0.5]
                }
            }
            // -- major grid
            for var x = -plate / 2; x <= plate / 2; x += 10 {
                if x != 0 {
                    planeLines += [-plate/2, x, 0.0]
                    planeLines += [plate/2, x, 0.0]
                    planeLines += [x, -plate/2, 0.0]
                    planeLines += [x, plate/2, 0.0]
                    planeRGB +=   [0.7,0.7,0.7,
                        0.7,0.7,0.7,
                        0.7,0.7,0.7,
                        0.7,0.7,0.7]
                    planeN += [0,0,1,
                        0,0,1,
                        0,0,1,
                        0,0,1]
                    planeA += [0.5,0.5,0.5,0.5]
                }
            }
            
            self.plane_vbo = [0,0,0,0]
            
            // prepare buffer for grid
            glGenBuffers(4, &self.plane_vbo)
            
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
            // set grid normal to 4th buffer
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.plane_vbo[3])
            glBufferData(GLenum(GL_ARRAY_BUFFER), planeN.count * sizeof(GLfloat), &planeN, GLenum(GL_STATIC_DRAW))
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
            
            self.pvcount = GLsizei(planeA.count)
        }
    }
}
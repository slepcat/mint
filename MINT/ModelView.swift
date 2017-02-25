//
//  ModelView.swift
//  MINT
//
//  Created by NemuNeko on 2014/10/16.
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
    var viewPt:ViewPoint = ViewPoint(x: 0,y: 0,z: 180)
    var distance : GLfloat = 300
    var viewAngle:ViewAngle = ViewAngle(x: 0.0, y: 0.0, z: 0.0)
    let zoomMax:Float = 1500
    let zoomMin:Float = 10
    
    // UI Settings: Axes & Plane
    var drawAxes : Bool = true
    var drawPlane : Bool = true
    
    var lightingShader:Shader? = nil
    
    // OpenGL Parameters
    let bgColor : [Float] = [0.90, 0.95, 0.97, 1]//Background Color, 7% Gray
    
    // Main stack of drawing objects.
    var stack : [GLvertices] = []
    var background : [GLvertices] = []
    
    //Attribute pointer for shader
    var gl_vertex:GLuint = 0
    var gl_normal:GLuint = 0
    var gl_color:GLuint = 0
    var gl_alpha:GLuint = 0
    var gl_MVP:GLint = 0
    var gl_V:GLint = 0
    var gl_M:GLint = 0
    var gl_light:GLint = 0
    
    //SwiftGL
    var perspective : mat4 = mat4(1.0)
    
    override func awakeFromNib() {
        let attribs : [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            //UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFADepthSize), UInt32(24),
            UInt32(NSOpenGLPFAColorSize), UInt32(24),
            UInt32(NSOpenGLPFAAlphaSize), UInt32(8),
            UInt32(NSOpenGLPFAMultisample),
            UInt32(NSOpenGLPFASampleBuffers), UInt32(1),
            UInt32(NSOpenGLPFASamples), UInt32(4),
            //UInt32(NSOpenGLPFAMinimumPolicy),
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0)
        ]
        
        if let format = NSOpenGLPixelFormat(attributes: attribs) {
            self.pixelFormat = format
        }
    }
    
    /*
    func mat2array(matrix: mat4) -> [GLfloat] {
        
        var acc : [GLfloat] = []
        
        for i in stride(from:0, to: 4, by: 1) {
            for j in stride(from:0, to: 4, by: 1) {
                acc.append(matrix[i][j])
            }
        }
        
        return acc
    }
    */
 

    
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        // Get shader source from NSBundle
        lightingShader = Shader.init(shaderName: "OpenJsCADLightingShader")
        
        if let shader = lightingShader {
            glUseProgram(shader.program)
            
            // Vertex id
            var attribId = glGetAttribLocation(shader.program, "vertexPosition_modelspace")
            if  attribId >= 0 {
                self.gl_vertex = numericCast(attribId)
            } else {
                Swift.print("failed to get gl_Vertex pos")
            }
            // Normal id
            attribId = glGetAttribLocation(shader.program, "vertexNormal_modelspace")
            if  attribId >= 0 {
                self.gl_normal = numericCast(attribId)
            } else {
                Swift.print("failed to get gl_Normal")
            }
            // Color id
            attribId = glGetAttribLocation(shader.program, "vertexColor_modelspace")
            if  attribId >= 0 {
                self.gl_color = numericCast(attribId)
            } else {
                Swift.print("failed to get vertexColor")
            }
            // Alpha id
            attribId = glGetAttribLocation(shader.program, "vertexAlpha_modelspace")
            if  attribId >= 0 {
                self.gl_alpha = numericCast(attribId)
            } else {
                Swift.print("failed to get vertexAlpha")
            }
            // MVP id
            attribId = glGetUniformLocation(shader.program, "MVP")
            if  attribId >= 0 {
                self.gl_MVP = numericCast(attribId)
            } else {
                Swift.print("failed to get MVP")
            }
            // V id
            attribId = glGetUniformLocation(shader.program, "V")
            if  attribId >= 0 {
                self.gl_V = numericCast(attribId)
            } else {
                Swift.print("failed to get V")
            }
            // M id
            attribId = glGetUniformLocation(shader.program, "M")
            if  attribId >= 0 {
                self.gl_M = numericCast(attribId)
            } else {
                Swift.print("failed to get M")
            }
            // Light pos id
            attribId = glGetUniformLocation(shader.program, "LightPosition_worldspace")
            if  attribId >= 0 {
                self.gl_light = numericCast(attribId)
            } else {
                Swift.print("failed to get LightPosition_worldspace")
            }
        } else {
            Swift.print("failed to init shader")
        }
        
        let aspect = GLfloat(self.frame.size.width / self.frame.size.height)
        perspective = mint_perspective(45, aspect, 0.5, 2500)
        
        glClearColor(bgColor[0], bgColor[1], bgColor[2], bgColor[3])
        
        // prepare axes and grid
        let a = Axes(leafID: 0, vattrib: gl_vertex, nattrib: gl_normal, cattrib: gl_color, aattrib: gl_alpha)
        a.setup()
        let p = GridPlane(leafID: 0, vattrib: gl_vertex, nattrib: gl_normal, cattrib: gl_color, aattrib: gl_alpha)
        p.setup()
        
        background = [a, p]
        
        
        /* debug triangle
        let triangle = TestTriangle(leafID: 0, vattrib: gl_vertex, nattrib: gl_normal, cattrib: gl_color, aattrib: gl_alpha)
        triangle.setup()
        stack.append(triangle)
        */
        
        Swift.print("open gl view prepared")
    }
    
    override func reshape() {
        let rect = self.bounds
        let aspect = GLfloat(self.frame.size.width / self.frame.size.height)
        glViewport(0, 0, GLsizei(rect.size.width), GLsizei(rect.size.height))
        perspective = mint_perspective(45, aspect, 0.5, 2500)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        glEnable(UInt32(GL_DEPTH_TEST))
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        //glDepthFunc(GLenum(GL_LESS))
        
        if let shader = lightingShader {
            glUseProgram(shader.program)
            //Swift.print(glGetError())
        }
        
        //Set Model View Matrix
        
        // caricurate rotation angle
        
        let ax : GLfloat = viewAngle.x * GLfloat(M_PI) / 180
        let ay : GLfloat = viewAngle.y * GLfloat(M_PI) / 180
        let az : GLfloat = viewAngle.z * GLfloat(M_PI) / 180
        
        //Swift.print("perspective: \(perspective)")
        
        let rotatex = rotateSlow(mat4(), ax, vec3(1,0,0))
        //Swift.print("rotatex: \(rotatex)")
        let rotatey = rotateSlow(mat4(), ay, vec3(0,1,0))
        //Swift.print("rotatey: \(rotatey)")
        let rotatez = rotateSlow(mat4(), az, vec3(0,0,1))
        //Swift.print("rotatez: \(rotatez)")
        
        let rotatem = rotatex * rotatey * rotatez
        //Swift.print("rotatem: \(rotatem)")
        let transm = mint_translate(mat4(), vec3(viewPt.x, viewPt.y, -viewPt.z))
        
        let view = transm * rotatem
        var viewm = view.arrayf()
        var mvp = (perspective * view).arrayf()
        var modelm = mat4().arrayf()
        
        //Swift.print("matrix output")
        //Swift.print(view)
        //Swift.print(perspective * view)
        
        glUniformMatrix4fv(gl_MVP, 1, GLboolean(GL_FALSE), &mvp)
        glUniformMatrix4fv(gl_V, 1, GLboolean(GL_FALSE), &viewm)
        glUniformMatrix4fv(gl_M, 1, GLboolean(GL_FALSE),&modelm)
        glUniform3f(gl_light, 1000, 1000, 1000)
        
        /* debug print
         
         if let shader = lightingShader {
         var mat = [GLfloat](repeating: 0, count: 16)
         
         glGetUniformfv(shader.program , gl_MVP, &mat[0])
         Swift.print(mat)
         }
         */
        
        self.drawObjects()
        
        glFlush()
        
        glDisable(GLenum(GL_BLEND))
        glDisable(GLenum(GL_DEPTH_TEST))
    }
    
    // draw mesh from stack
    func drawObjects() {
        
        var objects : [GLvertices] = []
        
        if drawAxes {
            objects += background
        }
        
        objects += stack
        
        for mesh in objects {
            if mesh.vao_id > 0 {
                
                //objc_sync_enter(mesh)
                
                glBindVertexArray(mesh.vao_id)
                //Swift.print(glGetError())
                
                glEnableVertexAttribArray(gl_vertex)
                glEnableVertexAttribArray(gl_color)
                glEnableVertexAttribArray(gl_normal)
                glEnableVertexAttribArray(gl_alpha)
                
                // 'count' is number of vertices
                glDrawArrays(mesh.drawtype, 0, mesh.buffersize / 3)
                
                glDisableVertexAttribArray(gl_vertex)
                glDisableVertexAttribArray(gl_color)
                glDisableVertexAttribArray(gl_normal)
                glDisableVertexAttribArray(gl_alpha)
                
                glBindVertexArray(0)
                
                //objc_sync_exit(mesh)
            }
        }
        
        //glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
    }
    
    // event handling
    // rotate view, zoom in/out, pan
    
    //rotate view when the mouse dragged with left button
    
    override func mouseDown(with theEvent: NSEvent) {
        
        //let clickPt: NSPoint = theEvent.locationInWindow
        //lastPt = self.convertPoint(clickPt, fromView: nil)
        //print("mouse down at X:\(lastPt.x), Y:\(lastPt.y)")
    }
    
    override func mouseDragged(with theEvent : NSEvent) {
        
        if !NSAlternateKeyMask.isSuperset(of: theEvent.modifierFlags) {
            //rotate z and y
            //rotateFactor is for speed control. but system delta value work fine
            //and I decided not to adjust it by user preference
            
            viewAngle.z -= Float(theEvent.deltaY)// * rotateFactor * 0.5
            
            if viewAngle.z >= 360 {
                viewAngle.z = fmod(viewAngle.z, 360)
            } else if viewAngle.y < 0 {
                viewAngle.z = 360 + fmod(viewAngle.z, 360)
            }
            viewAngle.y -= Float(theEvent.deltaX)// * rotateFactor
            if viewAngle.y >= 360 {
                viewAngle.y = fmod(viewAngle.y, 360)
            } else if viewAngle.y < 0 {
                viewAngle.y = 360 + fmod(viewAngle.y, 360)
            }
        } else {
            //rotate x and z
            
            viewAngle.z += Float(theEvent.deltaX)// * rotateFactor * 0.5
            
            if viewAngle.z >= 360 {
                viewAngle.z = fmod(viewAngle.y, 360)
            } else if viewAngle.z < 0 {
                viewAngle.z = 360 + fmod(viewAngle.z, 360)
            }
            viewAngle.x += Float(theEvent.deltaY)// * rotateFactor
            
            if viewAngle.x >= 360 {
                viewAngle.x = fmod(viewAngle.x, 360)
            } else if viewAngle.x < 0 {
                viewAngle.x = 360 + fmod(viewAngle.x, 360)
            }
        }
        
        //Swift.print("viewAngle.X:\(viewAngle.x),Y:\(viewAngle.y), Z:\(viewAngle.z)")
        
        self.needsDisplay = true
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        
        //let upPt:NSPoint = theEvent.locationInWindow
        //lastPt = self.convertPoint(upPt, fromView: nil)
        //print("mouse up at X:\(lastPt.x), Y:\(lastPt.y)")
    }
    
    //pan view when the mouse dragged with right button
    
    override func rightMouseDown(with theEvent: NSEvent) {
        
    }
    
    override func rightMouseDragged(with theEvent : NSEvent) {
        
    }
    
    override func rightMouseUp(with theEvent: NSEvent) {
        
    }
    
    //zoom in/out when mouse wheel scrolled
    
    override func scrollWheel(with theEvent: NSEvent) {
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
            
            //print("Zoom with coeff:\(coeff)")
            
            self.viewPt.z = self.zoomMin + coeff * (self.zoomMax - self.zoomMin)
            
            //print("view point changed to: \(viewPt.z)")
            
            self.needsDisplay = true
        }
    }
    
}

class GLvertices {
    // ID of leaf which is counterpart of GLmesh instance
    let leafID : UInt
    
    //open gl vao id
    var vao_id : GLuint = 0
    
    // draw tyep
    var drawtype : GLenum = 0
    
    //open gl buffer ids
    var vbufferid : GLuint = 0
    var nbufferid : GLuint = 0
    var cbufferid : GLuint = 0
    var abufferid : GLuint = 0
    
    //open gl attribute pointer ids
    var gl_vertex : GLuint = 0
    var gl_normal : GLuint = 0
    var gl_color : GLuint = 0
    var gl_alpha : GLuint = 0
    
    //length of mesh array
    var buffersize : GLsizei = 0
    
    init(leafID: UInt, vattrib: GLuint, nattrib: GLuint, cattrib: GLuint, aattrib: GLuint) {
        self.leafID = leafID
        gl_vertex = vattrib
        gl_normal = nattrib
        gl_color = cattrib
        gl_alpha = aattrib
    }
    
    deinit {
        if vao_id != 0 {
            glDeleteVertexArrays(1, &vao_id)
        }
        if vbufferid != 0 {
            glDeleteBuffers(1, &vbufferid)
        }
        if nbufferid != 0 {
            glDeleteBuffers(1, &nbufferid)
        }
        if cbufferid != 0 {
            glDeleteBuffers(1, &cbufferid)
        }
        if abufferid != 0 {
            glDeleteBuffers(1, &abufferid)
        }
    }
    
    func prepare_vao(vex: [GLfloat], normal: [GLfloat], color: [GLfloat], alpha: [GLfloat]) {
        // prepare_vao
        if vao_id == 0 {
            glGenVertexArrays(1, &vao_id)
        }
        
        glBindVertexArray(vao_id)
        
        // set up buffers
        prepare_buffer(vex: vex, id: &vbufferid, attrib_id: gl_vertex, attrib_size: 3) // Vertices buffer
        prepare_buffer(vex: normal, id: &nbufferid, attrib_id: gl_normal, attrib_size: 3) // Normals buffer
        prepare_buffer(vex: color, id: &cbufferid, attrib_id: gl_color, attrib_size: 3) // Color buffer
        prepare_buffer(vex: alpha, id: &abufferid, attrib_id: gl_alpha, attrib_size: 1) // Alpha buffer
        
        buffersize = GLsizei(vex.count)
        
        //glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)
    }
    
    func prepare_buffer(vex: [GLfloat], id: inout GLuint, attrib_id: GLuint, attrib_size: GLint) {
        if vex.count > 0 {
            var vex_m = vex
            
            if id == 0 {
                glGenBuffers(1, &id)
            }
            
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), id)
            glBufferData(GLenum(GL_ARRAY_BUFFER), vex_m.count * MemoryLayout<GLfloat>.size, &vex_m, GLenum(GL_STATIC_DRAW))
            
            glVertexAttribPointer(attrib_id, attrib_size, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
            glEnableVertexAttribArray(attrib_id)
            //glDisableVertexAttribArray(attrib_id)
        }
    }
}

/*
 class GLmesh:GLvertices{//MintObserver {
 
 // update open gl vertices & attribute array
 func update(subject: MintSubject, uid: UInt) {
 
 if uid == leafID {
 if let meshio = subject as? Mint3DPort {
 var glmesh = meshio.mesh()
 var glnormal = meshio.normal()
 var glcolor = meshio.color()
 //var glalpha = meshio.alpha()
 
 buffersize = GLsizei(glmesh.count)
 
 prepare_vao(glmesh, normal: glnormal, color: glcolor, alpha: [])
 
 }
 }
 }
 }
 */

class Axes : GLvertices {
    
    func setup() {
        // draw axes if required
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
        
        drawtype = GLenum(GL_LINES)
        
        prepare_vao(vex: axesLines, normal: axesN, color: axesRGB, alpha: axesA)
    }
}

class GridPlane : GLvertices {
    
    func setup() {
        let plate: GLfloat = 200
        
        var planeLines : [GLfloat] = []
        var planeRGB : [GLfloat] = []
        var planeA : [GLfloat] = []
        var planeN : [GLfloat] = []//normal
        // -- minor grid
        for x in stride(from: (-plate / 2), through: plate / 2, by: 1) {
            if (x.truncatingRemainder(dividingBy: 10)) != 0 {
                
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
        for x in stride(from: (-plate / 2), through: plate / 2, by: 10) {
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
        
        drawtype = GLenum(GL_LINES)
        // prepare buffer for grid
        prepare_vao(vex: planeLines, normal: planeN, color: planeRGB, alpha: planeA)
    }
}

class TestTriangle : GLvertices {
    
    func setup() {
        let vex : [GLfloat] = [50, 0, 0, 0, 50, 0, 30, 50, 20]
        let normal : [GLfloat] = [0, 0, -1, 0, 0, -1, 0, 1, 0]
        let color : [GLfloat] = [0.5,0.5,0.5, 0.5,0.5,0.5, 0.5,0.5,0.5]
        let alpha : [GLfloat] = [1, 1, 1]
        
        drawtype = GLenum(GL_TRIANGLES)
        prepare_vao(vex: vex, normal: normal, color: color, alpha: alpha)
    }
}


class GLmesh:GLvertices, MintObserver {
    
    // update open gl vertices & attribute array
    func update(_ subject: MintSubject, uid: UInt) {
        
        if uid == leafID {
            if let meshio = subject as? Mint3DPort {
                let glmesh = meshio.mesh_vex()
                let glnormal = meshio.mesh_normal()
                let glcolor = meshio.mesh_color()
                let glalpha = meshio.mesh_alpha()
                //let gldraw = meshio.drawtype()
                
                buffersize = GLsizei(glmesh.count)
                
                drawtype = GLenum(GL_TRIANGLES)
                
                prepare_vao(vex: glmesh, normal: glnormal, color: glcolor, alpha: glalpha)
            }
        }
    }
}

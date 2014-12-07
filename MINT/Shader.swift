//
//  Shader.swift
//  MINT
//
//  Created by 安藤 泰造 on 2014/11/30.
//  Copyright (c) 2014年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa
import OpenGL

@objc(Shader) class Shader {
    
    var program:GLuint = 0
    var positionSLot:GLint = 0
    var colorSlot:GLint = 0
    
    init?(shaderName:String) {
        
        //load shader source from the app bundle
        var vxShaderSource:UnsafePointer<CChar> = getVertexShaderSource(shaderName)
        var fgShaderSource:UnsafePointer<CChar> = getFragmentShaderSource(shaderName)
        
        //check cources
        if (vxShaderSource == nil)||(fgShaderSource == nil) {
            return nil
        }
        
        var vxSourceLength: GLint = numericCast(String.fromCString(vxShaderSource)!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        var fgSourceLength: GLint = numericCast(String.fromCString(fgShaderSource)!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        
        //prepare shader objects
        let vxShader : GLuint = glCreateShader(UInt32(GL_VERTEX_SHADER))
        let fgShader : GLuint = glCreateShader(UInt32(GL_FRAGMENT_SHADER))
        
        //set shader sources
        glShaderSource(vxShader, 1, &vxShaderSource, &vxSourceLength)
        glShaderSource(fgShader, 1, &fgShaderSource, &fgSourceLength)
        
        //compile shaders and check result
        glCompileShader(vxShader)
        var compiled:GLint = 0
        glGetShaderiv(vxShader, UInt32(GL_COMPILE_STATUS), &compiled)
        if compiled == GL_FALSE {
            println("failed to compile vxShader")
            return nil
        }
        
        glCompileShader(fgShader)
        glGetShaderiv(fgShader, UInt32(GL_COMPILE_STATUS), &compiled)
        if compiled == GL_FALSE {
            println("failed to compile fgShader")
            return nil
        }
        
        vxShaderSource = nil
        fgShaderSource = nil
        
        //prepare program and attach shaders
        self.program = glCreateProgram()
        
        glAttachShader(self.program, vxShader)
        glAttachShader(self.program, fgShader)
        
        //link and check result
        glLinkProgram(self.program)
        var linked:GLint = 0
        glGetProgramiv(self.program, UInt32(GL_LINK_STATUS), &linked)
        if linked == GL_FALSE {
            var buffSize:GLint = 0
            
            println("failed to link Shaders")
            glGetProgramiv(self.program, UInt32(GL_INFO_LOG_LENGTH) , &buffSize)
            
            if buffSize > 0 {
                var infoLog = UnsafeMutablePointer<CChar>.alloc(numericCast(buffSize))
                var l:GLsizei = 0
                
                glGetProgramInfoLog(self.program, buffSize, &l, infoLog)
                
                if let info = String.fromCString(infoLog) {
                    println(info)
                }
                
                infoLog.destroy()
            }
            
            return nil
        }
        
        glDeleteShader(vxShader)
        glDeleteShader(fgShader)
        
        self.positionSLot = glGetAttribLocation(self.program, "Position")
        self.colorSlot = glGetAttribLocation(self.program, "SourceColor")
    }
    
    func getShaderSource(shaderName: String, ext: String) -> UnsafePointer<CChar> {
        let appBundle = NSBundle.mainBundle()
        let shaderPath:String? = appBundle.pathForResource(shaderName, ofType: ext)
        
        if let path = shaderPath {
            let shaderSource = String.init(contentsOfFile: path, encoding:NSUTF8StringEncoding, error: nil)
            
            if let source = shaderSource {
                var shaderSourceC:UnsafePointer<CChar> = (source as NSString).UTF8String
                return shaderSourceC
            }
        }
        
        return nil
    }

    func getVertexShaderSource(shaderName: String) -> UnsafePointer<CChar> {
        return getShaderSource(shaderName, ext: "vs")
    }

    func getFragmentShaderSource(shaderName: String) -> UnsafePointer<CChar> {
        return getShaderSource(shaderName, ext: "fs")
    }
}
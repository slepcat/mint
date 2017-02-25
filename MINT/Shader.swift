//
//  Shader.swift
//  MINT
//
//  Created by NemuNeko on 2014/11/30.
//  Copyright (c) 2014年 Taizo A. All rights reserved.
//

import Foundation
import Cocoa
import OpenGL

class Shader {
    
    var program:GLuint = 0
    var positionSLot:GLint = 0
    var colorSlot:GLint = 0
    
    init?(shaderName:String) {
        
        //load shader source from the app bundle
        var vxShaderSource:UnsafePointer<CChar>? = getVertexShaderSource(shaderName)
        var fgShaderSource:UnsafePointer<CChar>? = getFragmentShaderSource(shaderName)
        
        //check cources
        if (vxShaderSource == nil)||(fgShaderSource == nil) {
            return nil
        }
        
        var vxSourceLength: GLint = numericCast(String(cString: vxShaderSource!).lengthOfBytes(using: String.Encoding.utf8))
        
        var fgSourceLength: GLint = numericCast(String(cString: fgShaderSource!).lengthOfBytes(using: String.Encoding.utf8))
        
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
            print("failed to compile vxShader")
            return nil
        }
        
        glCompileShader(fgShader)
        glGetShaderiv(fgShader, UInt32(GL_COMPILE_STATUS), &compiled)
        if compiled == GL_FALSE {
            print("failed to compile fgShader")
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
            
            print("failed to link Shaders")
            glGetProgramiv(self.program, UInt32(GL_INFO_LOG_LENGTH) , &buffSize)
            
            if buffSize > 0 {
                let infoLog = UnsafeMutablePointer<CChar>.allocate(capacity: numericCast(buffSize))
                var l:GLsizei = 0
                
                glGetProgramInfoLog(self.program, buffSize, &l, infoLog)
                
                print(String(cString: infoLog))
                
                infoLog.deinitialize()
            }
            
            return nil
        }
        
        glDeleteShader(vxShader)
        glDeleteShader(fgShader)
        
        self.positionSLot = glGetAttribLocation(self.program, "Position")
        self.colorSlot = glGetAttribLocation(self.program, "SourceColor")
    }
    
    func getShaderSource(_ shaderName: String, ext: String) -> UnsafePointer<CChar>? {
        let appBundle = Bundle.main
        let shaderPath:String? = appBundle.path(forResource: shaderName, ofType: ext)
        
        if let path = shaderPath {
            do {
                let shaderSource = try NSString(contentsOfFile: path, encoding:String.Encoding.utf8.rawValue)
                
                let shaderSourceC:UnsafePointer<CChar>? = shaderSource.utf8String
                return shaderSourceC
                
            } catch {
                print("failed to read shader source")
                return nil
            }
        }
        
        return nil
    }

    func getVertexShaderSource(_ shaderName: String) -> UnsafePointer<CChar>? {
        return getShaderSource(shaderName, ext: "vs")
    }

    func getFragmentShaderSource(_ shaderName: String) -> UnsafePointer<CChar>? {
        return getShaderSource(shaderName, ext: "fs")
    }
}

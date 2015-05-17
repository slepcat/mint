//
//  MintMatrix4x4UnitTest.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/05/17.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Quick
import Nimble

class Matrix4x4Spec : QuickSpec {
    override func spec() {
        it("should cariculate matrix multiply with vector correctly") {
            let elements : [Double] = [1, 2, 3, 4,
                                    5, 6, 7, 8,
                                    9, 10, 11, 12,
                                    0, 0, 0, 1]
            let matrix = Matrix4x4(matrix: elements)
            
            let testvec = Vector(x: 1, y: 2, z: 3)
            
            let result = matrix * testvec
            
            expect(result.x).to(equal(18.0))
            expect(result.y).to(equal(46.0))
            expect(result.z).to(equal(74.0))
        }
        
        it("should cariculate vector multiply with matrix correctly") {
            let elements : [Double] = [1, 2, 3, 0,
                5, 6, 7, 0,
                9, 10, 11, 0,
                0, 0, 0, 1]
            let matrix = Matrix4x4(matrix: elements)
            
            let testvec = Vector(x: 1, y: 2, z: 3)
            
            let result = testvec * matrix
            
            expect(result.x).to(equal(38.0))
            expect(result.y).to(equal(44.0))
            expect(result.z).to(equal(50.0))
        }
        
        it("should cariculate matrix multiply with malutiply correctly") {
            let elleft : [Double] = [1, 2, 3, 0,
                5, 6, 7, 0,
                9, 10, 11, 0,
                0, 0, 0, 1]
            let elright : [Double] = [1, 2, 3, 0,
                5, 6, 7, 0,
                9, 10, 11, 0,
                0, 0, 0, 1]
            let leftmat = Matrix4x4(matrix: elleft)
            let rightmat = Matrix4x4(matrix: elright)
            
            let result = leftmat * rightmat
            
            expect(result.elements[0]).to(equal(38))
            expect(result.elements[1]).to(equal(44))
            expect(result.elements[2]).to(equal(50))
            expect(result.elements[3]).to(equal(0))
            
            expect(result.elements[4]).to(equal(98))
            expect(result.elements[5]).to(equal(116))
            expect(result.elements[6]).to(equal(134))
            expect(result.elements[7]).to(equal(0))

            expect(result.elements[8]).to(equal(158))
            expect(result.elements[9]).to(equal(188))
            expect(result.elements[10]).to(equal(218))
            expect(result.elements[11]).to(equal(0))

            expect(result.elements[12]).to(equal(0))
            expect(result.elements[13]).to(equal(0))
            expect(result.elements[14]).to(equal(0))
            expect(result.elements[15]).to(equal(1))
        }
    }
}
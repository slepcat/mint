//
//  MintFoundationUnitTest.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/05/05.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Quick
import Nimble

class PolygonSpec : QuickSpec {
    override func spec() {
        
        var poly = Polygon(vertices: [Vertex(pos: Vector(x: 0, y: 5)), Vertex(pos: Vector(x: 4.7621, y: -1.5241)), Vertex(pos: Vector(x: -4.7621, y: -1.5241))])
        
        it("should have bounding box, which max is 6.9 and min is 5") {
            let result = poly.boundingBox()
            
            expect(result.min.length() - 5).to(beLessThan(0.1))
            expect(result.max.length() - 6.9).to(beLessThan(0.1))
        }
        
        it("should have bound, which center is 1.73 from origin and radius is 5.77") {
            let result = poly.boundingSphere()
            
            expect(result.middle.length() - 1.7348).to(beLessThan(0.1))
            expect(result.radius - 5.7722).to(beLessThan(0.1))
        }
        
        it("should split square polygon to 2 triangles") {
            let vexa = Vertex(pos: Vector(x: 0, y: 0, z: 0))
            let vexb = Vertex(pos: Vector(x: 0, y: 10, z: 0))
            let vexc = Vertex(pos: Vector(x: 10, y: 10, z: 0))
            let vexd = Vertex(pos: Vector(x: 10, y: 0, z: 0))
            let poly = Polygon(vertices: [vexa, vexb, vexc, vexd])
            
            let result = poly.triangulationConvex()
            
            expect(result.count).to(equal(2))
            expect(result.first?.vertices.count).to(equal(3))
            expect(result.last?.vertices.count).to(equal(3))
        }
        
        it("should evaluate square polygon as convex") {
            let vexa = Vertex(pos: Vector(x: 0, y: 0, z: 0))
            let vexb = Vertex(pos: Vector(x: 0, y: 10, z: 0))
            let vexc = Vertex(pos: Vector(x: 10, y: 10, z: 0))
            let vexd = Vertex(pos: Vector(x: 10, y: 0, z: 0))
            let poly = Polygon(vertices: [vexa, vexb, vexc, vexd])
            
            let result = poly.checkIfConvex()
            
            expect(result).to(equal(true))
        }
    }
}

class PlaneSpec : QuickSpec {
    override func spec() {
        
        // prepare plane to split polygon
        let veca = Vector(x: 3, y: -3)
        let vecb = Vector(x: 3, y: 3)
        let vecc = Vector(x: 0, y: 0)
        let plane = Plane(a: veca, b: vecb, c: vecc)
        
        it("should return coplanar_front polygon when it's coplanar front") {
            
            let vex = [Vertex(pos: veca), Vertex(pos: vecb), Vertex(pos: vecc)]
            let poly = Polygon(vertices: vex)
            
            let result = plane.splitPolygon(poly)
            
            expect(result.type).to(equal(BSP.Coplanar_front))
            expect(result.front).toNot(beNil())
            expect(result.back).to(beNil())
        }
        
        it("should return coplanar_back polygon when it's coplanar back") {
            let vex = [Vertex(pos: vecc), Vertex(pos: vecb), Vertex(pos: veca)]
            let poly = Polygon(vertices: vex)
            
            let result = plane.splitPolygon(poly)
            
            expect(result.type).to(equal(BSP.Coplanar_back))
            expect(result.front).to(beNil())
            expect(result.back).toNot(beNil())
        }
        
        it("should return front polygon when it's front") {
            let vexa = Vertex(pos: Vector(x: 3, y: -3, z: 10))
            let vexb = Vertex(pos: Vector(x: 3, y: 3, z: 10))
            let vexc = Vertex(pos: Vector(x: 0, y: 0, z: 10))
            let vex = [vexa, vexb, vexc]
            let poly = Polygon(vertices: vex)
            
            let result = plane.splitPolygon(poly)
            
            expect(result.type).to(equal(BSP.Front))
            expect(result.front).toNot(beNil())
            expect(result.back).to(beNil())
        }
        
        it("should return back polygon when it's back") {
            let vexa = Vertex(pos: Vector(x: 3, y: -3, z: -10))
            let vexb = Vertex(pos: Vector(x: 3, y: 3, z: -10))
            let vexc = Vertex(pos: Vector(x: 0, y: 0, z: -10))
            let vex = [vexa, vexb, vexc]
            let poly = Polygon(vertices: vex)
            
            let result = plane.splitPolygon(poly)
            
            expect(result.type).to(equal(BSP.Back))
            expect(result.front).to(beNil())
            expect(result.back).toNot(beNil())
        }
        
        it("should return splitted polygon when it's spanning") {
            let vexa = Vertex(pos: Vector(x: 3, y: -3, z: 1))
            let vexb = Vertex(pos: Vector(x: 3, y: 3, z: 1))
            let vexc = Vertex(pos: Vector(x: 0, y: 0, z: -1))
            let vex = [vexa, vexb, vexc]
            let poly = Polygon(vertices: vex)
            
            let result = plane.splitPolygon(poly)
            
            expect(result.type).to(equal(BSP.Spanning))
            expect(result.front).toNot(beNil())
            expect(result.back).toNot(beNil())
        }
    }
}
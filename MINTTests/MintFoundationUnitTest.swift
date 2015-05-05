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
            let csg = PolygonTreeNode()
            csg.polygon = poly
            
            var cpfront = [PolygonTreeNode](), cpback = [PolygonTreeNode](), front = [PolygonTreeNode](), back = [PolygonTreeNode]()
            
            csg.splitByPlane(plane, cpfrontnodes: &cpfront, cpbacknodes: &cpback, frontnodes: &front, backnodes: &back)
            
            expect(cpfront.count).to(equal(1))
            expect(cpback.count).to(equal(0))
            expect(front.count).to(equal(0))
            expect(back.count).to(equal(0))
        }
        
        it("should return coplanar_back polygon when it's coplanar back") {
            let vex = [Vertex(pos: vecc), Vertex(pos: vecb), Vertex(pos: veca)]
            let poly = Polygon(vertices: vex)
            
            let result = plane.splitPolygon(poly)
            
            expect(result.cpfront.count).to(equal(0))
            expect(result.cpback.count).to(equal(1))
            expect(result.front.count).to(equal(0))
            expect(result.back.count).to(equal(0))
        }
        
        it("should return front polygon when it's front") {
            
        }
        
        it("should return back polygon when it's back") {
            
        }
        
        it("should return splitted polygon when it's spanning") {
            
        }
    }
}
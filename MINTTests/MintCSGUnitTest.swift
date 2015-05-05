//
//  MintCSGUnitTest.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/05/04.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation
import Quick
import Nimble

class SplitByPlaneSpec : QuickSpec {
    override func spec() {
        
        // prepare plane to split polygon
        let veca = Vector(x: 3, y: -3)
        let vecb = Vector(x: 3, y: 3)
        let vecc = Vector(x: 0, y: 0)
        let plane = Plane(a: veca, b: vecb, c: vecc)
        
        it("shouldn't split coplanar_front polygon") {
            
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
        
        it("shouldn't split coplanar_back polygon") {
            
            let vex = [Vertex(pos: vecc), Vertex(pos: vecb), Vertex(pos: veca)]
            let poly = Polygon(vertices: vex)
            let csg = PolygonTreeNode()
            csg.polygon = poly
            
            var cpfront = [PolygonTreeNode](), cpback = [PolygonTreeNode](), front = [PolygonTreeNode](), back = [PolygonTreeNode]()
            
            csg.splitByPlane(plane, cpfrontnodes: &cpfront, cpbacknodes: &cpback, frontnodes: &front, backnodes: &back)
            
            expect(cpfront.count).to(equal(0))
            expect(cpback.count).to(equal(1))
            expect(front.count).to(equal(0))
            expect(back.count).to(equal(0))
        }
        
        it("should put front polygon in 'frontnode'") {
            let vexa = Vertex(pos: Vector(x: 3, y: -3, z: 10))
            let vexb = Vertex(pos: Vector(x: 3, y: 3, z: 10))
            let vexc = Vertex(pos: Vector(x: 0, y: 0, z: 10))
            let vex = [vexa, vexb, vexc]
            let poly = Polygon(vertices: vex)
            let csg = PolygonTreeNode()
            csg.polygon = poly
            
            var cpfront = [PolygonTreeNode](), cpback = [PolygonTreeNode](), front = [PolygonTreeNode](), back = [PolygonTreeNode]()
            
            csg.splitByPlane(plane, cpfrontnodes: &cpfront, cpbacknodes: &cpback, frontnodes: &front, backnodes: &back)
            
            expect(cpfront.count).to(equal(0))
            expect(cpback.count).to(equal(0))
            expect(front.count).to(equal(1))
            expect(back.count).to(equal(0))
        }
        
        it("should put back polygon in 'backnode'") {
            let vexa = Vertex(pos: Vector(x: 3, y: -3, z: -10))
            let vexb = Vertex(pos: Vector(x: 3, y: 3, z: -10))
            let vexc = Vertex(pos: Vector(x: 0, y: 0, z: -10))
            let vex = [vexa, vexb, vexc]
            let poly = Polygon(vertices: vex)
            let csg = PolygonTreeNode()
            csg.polygon = poly
            
            var cpfront = [PolygonTreeNode](), cpback = [PolygonTreeNode](), front = [PolygonTreeNode](), back = [PolygonTreeNode]()
            
            csg.splitByPlane(plane, cpfrontnodes: &cpfront, cpbacknodes: &cpback, frontnodes: &front, backnodes: &back)
            
            expect(cpfront.count).to(equal(0))
            expect(cpback.count).to(equal(0))
            expect(front.count).to(equal(0))
            expect(back.count).to(equal(1))
        }
        
        it("should split 'spanning' polygon") {
            let vexa = Vertex(pos: Vector(x: 3, y: -3, z: 1))
            let vexb = Vertex(pos: Vector(x: 3, y: 3, z: 1))
            let vexc = Vertex(pos: Vector(x: 0, y: 0, z: -1))
            let vex = [vexa, vexb, vexc]
            let poly = Polygon(vertices: vex)
            let csg = PolygonTreeNode()
            csg.polygon = poly
            
            var cpfront = [PolygonTreeNode](), cpback = [PolygonTreeNode](), front = [PolygonTreeNode](), back = [PolygonTreeNode]()
            
            csg.splitByPlane(plane, cpfrontnodes: &cpfront, cpbacknodes: &cpback, frontnodes: &front, backnodes: &back)
            
            expect(cpfront.count).to(equal(0))
            expect(cpback.count).to(equal(0))
            expect(front.count).to(equal(1))
            expect(back.count).to(equal(1))
        }
    }
}
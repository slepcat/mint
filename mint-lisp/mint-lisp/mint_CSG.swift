//
//  mint_CSG.swift
//  MINT
//
//  Created by NemuNeko on 2015/05/04.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

// # class PolygonTreeNode
// This class manages hierarchical splits of polygons
// At the top is a root node which doesn hold a polygon, only child PolygonTreeNodes
// Below that are zero or more 'top' nodes; each holds a polygon. The polygons can be in different planes
// splitByPlane() splits a node by a plane. If the plane intersects the polygon, two new child nodes
// are created holding the splitted polygon.
// getPolygons() retrieves the polygon from the tree. If for PolygonTreeNode the polygon is split but
// the two split parts (child nodes) are still intact, then the unsplit polygon is returned.
// This ensures that we can safely split a polygon into many fragments. If the fragments are untouched,
//  getPolygons() will return the original unsplit polygon instead of the fragments.
// remove() removes a polygon from the tree. Once a polygon is removed, the parent polygons are invalidated
// since they are no longer intact.
// constructor creates the root node:
class PolygonTreeNode {
    var parent : PolygonTreeNode? = nil
    var children : [PolygonTreeNode] = []
    var polygon : Polygon? = nil
    var removed : Bool = false
    
    // fill the tree with polygons. Should be called on the root node only; child nodes must
    // always be a derivate (split) of the parent node.
    func addPolygons(poly: [Polygon]) {
        if !isRootNode() {
            for p in poly {
                addChild(p)
            }
        }
        // new polygons can only be added to root node; children can only be splitted polygons
        //MintErr.exc.raise()
    }
    
    // remove a node
    // - the siblings become toplevel nodes
    // - the parent is removed recursively
    func remove() {
        if removed == false {
            removed = true
            
            // remove ourselves from the parent's children list:
            if let parentcsg = parent {
                
                for var i = 0; parentcsg.children.count > i; i++ {
                    if parentcsg.children[i] === self {
                        parentcsg.children.removeAtIndex(i)
                        i--
                    }
                }
                // invalidate the parent's polygon, and of all parents above it:
                parentcsg.recursivelyInvalidatePolygon()
            }
        }
    }
    
    func isRootNode() -> Bool {
        if parent == nil {
            return true
        } else {
            return false
        }
    }
    
    // invert all polygons in the tree. Call on the root node
    func invert() {
        if isRootNode() {// can only call this on the root node
            invertSub()
        } else {
            print("Assertion failed", terminator: "\n")
        }
    }
    
    func getPolygon() -> Polygon? {
        if let poly = polygon {
            return poly
        } else { // doesn't have a polygon, which means that it has been broken down
            print("Assertion failed", terminator: "\n")
            return nil
        }
    }
    
    func getPolygons() -> [Polygon] {
        if let poly = polygon {
            // the polygon hasn't been broken yet. We can ignore the children and return our polygon:
            return [poly]
        } else {
            // our polygon has been split up and broken, so gather all subpolygons from the children:
            var childpolygons = [Polygon]()
            for child in children {
                childpolygons += child.getPolygons()
            }
            
            return childpolygons
        }
    }
    
    // split the node by a plane; add the resulting nodes to the frontnodes and backnodes array
    // If the plane doesn't intersect the polygon, the 'this' object is added to one of the arrays
    // If the plane does intersect the polygon, two new child nodes are created for the front and back fragments,
    //  and added to both arrays.
    /* original
    func splitByPlane(plane: Plane, inout cpfrontnodes: [PolygonTreeNode], inout cpbacknodes: [PolygonTreeNode], inout frontnodes: [PolygonTreeNode], inout backnodes: [PolygonTreeNode]) {
        
        if children.count > 0 {
            // if we have children, split the children
            for child in children {
                child.splitByPlane(plane, cpfrontnodes: &cpfrontnodes, cpbacknodes: &cpbacknodes, frontnodes: &frontnodes, backnodes: &backnodes)
            }
        } else {
            // no children. Split the polygon:
            if polygon != nil {
                let bound = polygon!.boundingSphere()
                var sphereradius = bound.radius + 1e-4
                var planenormal = plane.normal
                var spherecenter = bound.middle
                var d = planenormal.dot(spherecenter) - plane.w
                
                if d > sphereradius {
                    frontnodes.append(self)
                } else if d < -sphereradius {
                    backnodes.append(self)
                } else {
                    let splitresult = plane.splitPolygon(polygon!)
                    switch splitresult.type {
                    case .Coplanar_front:
                        // coplanar front:
                        cpfrontnodes.append(self)
                    case .Coplanar_back:
                        // coplanar back:
                        cpbacknodes.append(self)
                    case .Front:
                        // front:
                        frontnodes.append(self)
                    case .Back:
                        // back:
                        backnodes.append(self)
                    case .Spanning:
                        // spanning:
                        if let front = splitresult.front {
                            var frontnode = addChild(front)
                            frontnodes.append(frontnode)
                        }
                        if let back = splitresult.back {
                            var backnode = addChild(back)
                            backnodes.append(backnode)
                        }
                    default:
                        print("unexpected err")
                        break
                    }
                }
            }
        }
    }
    */
    
    // Slightly modified. This ver of splitByPlane() does not have 'cpbacknodes' argument,
    // because Swift cannot have 2 arguments of same reference.
    func splitByPlane(plane: Plane, inout cpfrontnodes: [PolygonTreeNode], inout frontnodes: [PolygonTreeNode], inout backnodes: [PolygonTreeNode]) {
        
        if children.count > 0 {
            // if we have children, split the children
            for child in children {
                child.splitByPlane(plane, cpfrontnodes: &cpfrontnodes, frontnodes: &frontnodes, backnodes: &backnodes)
            }
        } else {
            // no children. Split the polygon:
            if polygon != nil {
                let bound = polygon!.boundingSphere()
                let sphereradius = bound.radius + 1e-4
                let planenormal = plane.normal
                let spherecenter = bound.middle
                let d = planenormal.dot(spherecenter) - plane.w
                
                if d > sphereradius {
                    frontnodes.append(self)
                } else if d < -sphereradius {
                    backnodes.append(self)
                } else {
                    let splitresult = plane.splitPolygon(polygon!)
                    switch splitresult.type {
                    case .Coplanar_front:
                        // coplanar front:
                        cpfrontnodes.append(self)
                    case .Coplanar_back:
                        // coplanar back:
                        backnodes.append(self)
                    case .Front:
                        // front:
                        frontnodes.append(self)
                    case .Back:
                        // back:
                        backnodes.append(self)
                    case .Spanning:
                        // spanning:
                        if let front = splitresult.front {
                            let frontnode = addChild(front)
                            frontnodes.append(frontnode)
                        }
                        if let back = splitresult.back {
                            let backnode = addChild(back)
                            backnodes.append(backnode)
                        }
                    default:
                        print("unexpected err", terminator: "\n")
                        break
                    }
                }
            }
        }
    }
    
    // PRIVATE methods from here:
    // add child to a node
    // this should be called whenever the polygon is split
    // a child should be created for every fragment of the split polygon
    // returns the newly created child
    private func addChild(poly: Polygon) -> PolygonTreeNode {
        let newchild = PolygonTreeNode()
        newchild.parent = self
        newchild.polygon = poly
        self.children.append(newchild)
        return newchild
    }
    
    
    private func invertSub() {
        if let poly = polygon {
            polygon = poly.flipped()
        }
        
        for child in children {
            child.invertSub()
        }
    }
    
    private func recursivelyInvalidatePolygon() {
        if polygon != nil {
            polygon = nil
            if let parentcsg = parent {
                parentcsg.recursivelyInvalidatePolygon()
            }
        }
    }
    
}

// # class MeshTree
// This is the root of a BSP tree
// We are using this separate class for the root of the tree, to hold the PolygonTreeNode root
// The actual tree is kept in this.rootnode

class MeshTree {
    var polygonTree : PolygonTreeNode
    var rootnode : Node
    
    init(polygons : [Polygon]) {
        polygonTree = PolygonTreeNode()
        rootnode = Node(parent: nil)
        if polygons.count > 0 {
            addPolygons(polygons)
        }
    }

    func invert() {
        polygonTree.invert()
        rootnode.invert()
    }
    
    // Remove all polygons in this BSP tree that are inside the other BSP tree
    // `tree`.
    func clipTo(tree: MeshTree, alsoRemovecoplanarFront: Bool) {
        rootnode.clipTo(tree, alsoRemovecoplanarFront: alsoRemovecoplanarFront)
    }
    
    func allPolygons() -> [Polygon] {
        return polygonTree.getPolygons()
    }
    
    func addPolygons(polygons : [Polygon]) {
        
        var polygontreenodes : [PolygonTreeNode] = []
        
        for poly in polygons {
            polygontreenodes += [polygonTree.addChild(poly)]
        }
        rootnode.addPolygonTreeNodes(polygontreenodes)
    }
}

// # class Node
// Holds a node in a BSP tree. A BSP tree is built from a collection of polygons
// by picking a polygon to split along.
// Polygons are not stored directly in the tree, but in PolygonTreeNodes, stored in
// this.polygontreenodes. Those PolygonTreeNodes are children of the owning
// CSG.Tree.polygonTree
// This is not a leafy BSP tree since there is
// no distinction between internal and leaf nodes.
class Node {
    var plane : Plane? = nil
    var front : Node? = nil
    var back : Node? = nil
    var polyTreeNodes : [PolygonTreeNode] = []
    var parent : Node?
    
    init(parent: Node?) {
        self.parent = parent
    }
    
    // Convert solid space to empty space and empty space to solid space.
    func invert() {
        if let p = plane {
            plane = p.flipped()
        }
        if let f = front {
            f.invert()
        }
        if let b = back {
            b.invert()
        }
        let temp = front
        front = back
        back = temp
    }
    
    // clip polygontreenodes to our plane
    // calls remove() for all clipped PolygonTreeNodes
    func clipPolygons(ptNodes: [PolygonTreeNode], alsoRemovecoplanarFront: Bool) {
        if let p = plane {
            var backnodes = [PolygonTreeNode]()
            var frontnodes = [PolygonTreeNode]()
            var coplanarfrontnodes = alsoRemovecoplanarFront ? backnodes : frontnodes
            
            for node in ptNodes {
                if !node.removed {
                    node.splitByPlane(p, cpfrontnodes: &coplanarfrontnodes, frontnodes: &frontnodes, backnodes: &backnodes)
                }
            }
            
            if let f = front {
                if frontnodes.count > 0 {
                    f.clipPolygons(frontnodes, alsoRemovecoplanarFront: alsoRemovecoplanarFront)
                }
            }
            
            if (back != nil) && (backnodes.count > 0) {
                back!.clipPolygons(backnodes, alsoRemovecoplanarFront: alsoRemovecoplanarFront)
            } else {
                // there's nothing behind this plane. Delete the nodes behind this plane:
                for  node in backnodes {
                    node.remove()
                }
            }
        }
    }
    
    // Remove all polygons in this BSP tree that are inside the other BSP tree
    // `tree`.
    func clipTo(tree: MeshTree, alsoRemovecoplanarFront: Bool) {
        if polyTreeNodes.count > 0 {
            tree.rootnode.clipPolygons(polyTreeNodes, alsoRemovecoplanarFront: alsoRemovecoplanarFront)
        }
        
        if let f = front {
            f.clipTo(tree, alsoRemovecoplanarFront: alsoRemovecoplanarFront)
        }
        
        if let b = back {
            b.clipTo(tree, alsoRemovecoplanarFront: alsoRemovecoplanarFront)
        }
    }
    
    func addPolygonTreeNodes(polygontreenodes: [PolygonTreeNode]) {
        if polygontreenodes.count > 0 {
            if plane == nil {
                let bestplane = polygontreenodes[0].getPolygon()?.plane
                plane = bestplane;
            }
            var frontnodes : [PolygonTreeNode] = []
            var backnodes : [PolygonTreeNode] = []
            
            for node in polygontreenodes {
                node.splitByPlane(plane!, cpfrontnodes: &self.polyTreeNodes, frontnodes: &frontnodes, backnodes: &backnodes)
            }
            
            if frontnodes.count > 0 {
                if front == nil {
                    front = Node(parent: self)
                }
                if let f = front {
                    f.addPolygonTreeNodes(frontnodes)
                }
            }
            
            if backnodes.count > 0 {
                if back == nil {
                    back = Node(parent: self)
                }
                if let b = back {
                    b.addPolygonTreeNodes(backnodes)
                }
            }
        }
    }
    
    func getParentPlaneNormals(inout normals: [Vector], maxdepth: Int) {
        if maxdepth > 0 {
            if let p = parent {
                normals.append(p.plane!.normal)
                p.getParentPlaneNormals(&normals, maxdepth: maxdepth - 1);
            }
        }
    }
}

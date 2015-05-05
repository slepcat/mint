//
//  MintCSG.swift
//  MINT
//
//  Created by 安藤 泰造 on 2015/05/04.
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
                var parentschildren = parentcsg.children
                
                for var i = 0; parentschildren.count > i; i++ {
                    if parentschildren[i] === self {
                        parentschildren.removeAtIndex(i)
                        i--
                    }
                }
                // invalidate the parent's polygon, and of all parents above it:
                //parentcsg.recursivelyInvalidatePolygon()
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
            //invertSub()
        } else {
            println("Assertion failed")
        }
    }
    
    func getPolygon() -> Polygon? {
        if let poly = polygon {
            return poly
        } else { // doesn't have a polygon, which means that it has been broken down
            println("Assertion failed")
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
                    case 0:
                        // coplanar front:
                        coplanarfrontnodes.push(this);
                        break;
                        
                    case 1:
                        // coplanar back:
                        coplanarbacknodes.push(this);
                        break;
                        
                    case 2:
                        // front:
                        frontnodes.push(this);
                        break;
                        
                    case 3:
                        // back:
                        backnodes.push(this);
                        break;
                        
                    case 4:
                        // spanning:
                        if(splitresult.front) {
                            var frontnode = this.addChild(splitresult.front);
                            frontnodes.push(frontnode);
                        }
                        if(splitresult.back) {
                            var backnode = this.addChild(splitresult.back);
                            backnodes.push(backnode);
                        }
                        break;
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
    func addChild(poly: Polygon) -> PolygonTreeNode {
        var newchild = PolygonTreeNode()
        newchild.parent = self
        newchild.polygon = polygon
        self.children.append(newchild)
        return newchild
    }
    
    /*
    func invertSub() {
        if polygon.count > 0 {
            polygon = polygon.flipped()
        }
        this.children.map(function(child) {
            child.invertSub();
            });
    }
    
    func recursivelyInvalidatePolygon() {
        if(this.polygon) {
            this.polygon = null;
            if(this.parent) {
                this.parent.recursivelyInvalidatePolygon();
            }
        }
    }
    */
}

/*

// # class Tree
// This is the root of a BSP tree
// We are using this separate class for the root of the tree, to hold the PolygonTreeNode root
// The actual tree is kept in this.rootnode
CSG.Tree = function(polygons) {
    this.polygonTree = new CSG.PolygonTreeNode();
    this.rootnode = new CSG.Node(null);
    if(polygons) this.addPolygons(polygons);
};

CSG.Tree.prototype = {
    invert: function() {
        this.polygonTree.invert();
        this.rootnode.invert();
    },
    
    // Remove all polygons in this BSP tree that are inside the other BSP tree
    // `tree`.
    clipTo: function(tree, alsoRemovecoplanarFront) {
        alsoRemovecoplanarFront = alsoRemovecoplanarFront ? true : false;
        this.rootnode.clipTo(tree, alsoRemovecoplanarFront);
    },
    
    allPolygons: function() {
        var result = [];
        this.polygonTree.getPolygons(result);
        return result;
    },
    
    addPolygons: function(polygons) {
        var _this = this;
        var polygontreenodes = polygons.map(function(p) {
            return _this.polygonTree.addChild(p);
            });
        this.rootnode.addPolygonTreeNodes(polygontreenodes);
    }
};

// # class Node
// Holds a node in a BSP tree. A BSP tree is built from a collection of polygons
// by picking a polygon to split along.
// Polygons are not stored directly in the tree, but in PolygonTreeNodes, stored in
// this.polygontreenodes. Those PolygonTreeNodes are children of the owning
// CSG.Tree.polygonTree
// This is not a leafy BSP tree since there is
// no distinction between internal and leaf nodes.
CSG.Node = function(parent) {
    this.plane = null;
    this.front = null;
    this.back = null;
    this.polygontreenodes = [];
    this.parent = parent;
};

CSG.Node.prototype = {
    // Convert solid space to empty space and empty space to solid space.
    invert: function() {
        if(this.plane) this.plane = this.plane.flipped();
        if(this.front) this.front.invert();
        if(this.back) this.back.invert();
        var temp = this.front;
        this.front = this.back;
        this.back = temp;
    },
    
    // clip polygontreenodes to our plane
    // calls remove() for all clipped PolygonTreeNodes
    clipPolygons: function(polygontreenodes, alsoRemovecoplanarFront) {
        if(this.plane) {
            var backnodes = [];
            var frontnodes = [];
            var coplanarfrontnodes = alsoRemovecoplanarFront ? backnodes : frontnodes;
            var plane = this.plane;
            var numpolygontreenodes = polygontreenodes.length;
            for(var i = 0; i < numpolygontreenodes; i++) {
                var node = polygontreenodes[i];
                if(!node.isRemoved()) {
                    node.splitByPlane(plane, coplanarfrontnodes, backnodes, frontnodes, backnodes);
                }
            }
            if(this.front && (frontnodes.length > 0)) {
                this.front.clipPolygons(frontnodes, alsoRemovecoplanarFront);
            }
            var numbacknodes = backnodes.length;
            if(this.back && (numbacknodes > 0)) {
                this.back.clipPolygons(backnodes, alsoRemovecoplanarFront);
            } else {
                // there's nothing behind this plane. Delete the nodes behind this plane:
                for(var i = 0; i < numbacknodes; i++) {
                    backnodes[i].remove();
                }
            }
        }
    },
    
    // Remove all polygons in this BSP tree that are inside the other BSP tree
    // `tree`.
    clipTo: function(tree, alsoRemovecoplanarFront) {
        if(this.polygontreenodes.length > 0) {
            tree.rootnode.clipPolygons(this.polygontreenodes, alsoRemovecoplanarFront);
        }
        if(this.front) this.front.clipTo(tree, alsoRemovecoplanarFront);
        if(this.back) this.back.clipTo(tree, alsoRemovecoplanarFront);
    },
    
    addPolygonTreeNodes: function(polygontreenodes) {
        if(polygontreenodes.length === 0) return;
        var _this = this;
        if(!this.plane) {
            var bestplane = polygontreenodes[0].getPolygon().plane;
            /*
            var parentnormals = [];
            this.getParentPlaneNormals(parentnormals, 6);
            //parentnormals = [];
            var numparentnormals = parentnormals.length;
            var minmaxnormal = 1.0;
            polygontreenodes.map(function(polygontreenode){
            var plane = polygontreenodes[0].getPolygon().plane;
            var planenormal = plane.normal;
            var maxnormaldot = -1.0;
            parentnormals.map(function(parentnormal){
            var dot = parentnormal.dot(planenormal);
            if(dot > maxnormaldot) maxnormaldot = dot;
            });
            if(maxnormaldot < minmaxnormal)
            {
            minmaxnormal = maxnormaldot;
            bestplane = plane;
            }
            });
            */
            this.plane = bestplane;
        }
        var frontnodes = [];
        var backnodes = [];
        polygontreenodes.map(function(polygontreenode) {
            polygontreenode.splitByPlane(_this.plane, _this.polygontreenodes, backnodes, frontnodes, backnodes);
            });
        if(frontnodes.length > 0) {
            if(!this.front) this.front = new CSG.Node(this);
            this.front.addPolygonTreeNodes(frontnodes);
        }
        if(backnodes.length > 0) {
            if(!this.back) this.back = new CSG.Node(this);
            this.back.addPolygonTreeNodes(backnodes);
        }
    },
    
    getParentPlaneNormals: function(normals, maxdepth) {
        if(maxdepth > 0) {
            if(this.parent) {
                normals.push(this.parent.plane.normal);
                this.parent.getParentPlaneNormals(normals, maxdepth - 1);
            }
        }
    }
};

*/
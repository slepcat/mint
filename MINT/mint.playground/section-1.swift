// Playground - noun: a place where people can play

import Foundation
//import Cocoa
import OpenGL

struct Vector {
    let x:Double
    let y:Double
    let z:Double
    
    init(x:Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(x:Double, y:Double) {
        self.x = x
        self.y = y
        self.z = 0
    }
    
    init(vector:Vector) {
        self = vector
    }
    
    init(_ array:[Double]) {
        switch array.count {
        case 0:
            self.x = 0
            self.y = 0
            self.z = 0
        case 1:
            self.x = array[0]
            self.y = array[0]
            self.z = array[0]
        case 2:
            self.x = array[0]
            self.y = array[1]
            self.z = 0
        default:
            self.x = array[0]
            self.y = array[1]
            self.z = array[2]
        }
    }
    
    func negated() -> Vector {
        return Vector(x:-self.x, y:-self.y, z:-self.z)
    }
    
    func abs() -> Vector {
        return Vector(x: fabs(self.x) , y: fabs(self.y) , z: fabs(self.z))
    }
    
    func times(k:Double) -> Vector {
        return Vector(x: k * self.x, y: k * self.y , z: k * self.z)
    }
    
    func dividedBy(k: Double) -> Vector {
        return Vector(x: self.x / k , y: self.y / k , z: self.z / k)
    }
    
    func dot(a: Vector) -> Double {
        return (self.x * a.x) + (self.y * a.y) + (self.z * a.z)
    }
    
    func cross(a: Vector) -> Vector {
        return Vector(x: self.y * a.z - self.z * a.y,y: self.z * a.x - self.x * a.z,z: self.x * a.y - self.y * a.x)
    }
    
    func lerp(vector a: Vector, k: Double) -> Vector {
        return Vector(vector: self + (a - self).times(k))
    }
    
    func lengthSquared() -> Double {
        return self.dot(self);
    }
    
    func length() -> Double {
        return sqrt(lengthSquared())
    }
    
    func unit() -> Vector {
        return self.dividedBy(self.length())
    }
    
    func distanceTo(a: Vector) -> Double {
        return (self - a).length()
    }
    
    func distanceToSquared(a: Vector) -> Double {
        return (self - a).lengthSquared()
    }
    
    func equals(a: Vector) -> Bool {
        return ((self.x == a.x) && (self.y == a.y) && (self.z == a.z))
    }
    
    /*
    // Right multiply by a 4x4 matrix (the vector is interpreted as a row vector)
    // Returns a new CSG.Vector3D
    multiply4x4: function(matrix4x4) {
    return matrix4x4.leftMultiply1x3Vector(this);
    },
    
    transform: function(matrix4x4) {
    return matrix4x4.leftMultiply1x3Vector(this);
    }
    */
    
    func toStlString() -> String {
        return "\(self.x) \(self.y) \(self.z)"
    }
    
    func toAMFString() -> String {
        return "<x>\(self.x)</x><y>\(self.y)</y><z>\(self.z)</z>"
    }
    
    func toString() -> String {
        return "(\(self.x), \(self.y), \(self.z))" //need to add fixedTo()
    }
    
    // find a vector that is somewhat perpendicular to this one
    func randomNonParallelVector() -> Vector {
        let abs = self.abs()
        
        if (abs.x <= abs.y) && (abs.x <= abs.z) {
            return Vector(x: 1,y: 0,z: 0)
        } else if (abs.y <= abs.x) && (abs.y <= abs.z) {
            return Vector(x: 0,y: 1,z: 0)
        } else {
            return Vector(x: 0,y: 0,z: 1)
        }
    }
    
    func min(a: Vector) -> Vector {
        return Vector(x: fmin(self.x, a.x), y: fmin(self.y, a.y), z: fmin(self.z, a.z))
    }
    
    func max(a: Vector) -> Vector {
        return Vector(x: fmax(self.x, a.x), y: fmax(self.y, a.y),z: fmax(self.z, a.z))
    }
}

func + (left: Vector, right:Vector) -> Vector {
    return Vector(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}

func - (left: Vector, right:Vector) -> Vector {
    return Vector(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}

struct Vertex {
    let pos : Vector
    lazy var normal : Vector = Vector(x: 0, y: 0, z: 0)
    var color = [GLfloat](count: 3, repeatedValue: 0.5)
    
    // defined by `CSG.Vertex`.
    init(pos: Vector) {
        self.pos = pos
        //self.normal = Vector(x: 0, y: 0, z: 0)
    }
    
    // Return a vertex with all orientation-specific data (e.g. vertex normal) flipped. Called when the
    // orientation of a polygon is flipped.
    func flipped() -> Vertex {
        return self
    }
    
    // Create a new vertex between this vertex and `other` by linearly
    // interpolating all properties using a parameter of `t`. Subclasses should
    // override this to interpolate additional properties.
    func interpolate(other: Vertex, t: Double) -> Vertex {
        var newpos = self.pos.lerp(vector: other.pos, k: t)
        return Vertex(pos: newpos)
    }
    
    /*
    // Affine transformation of vertex. Returns a new CSG.Vertex
    func transform(matrix: matrix4x4) -> Vertex {
    var newpos = this.pos.multiply4x4(matrix4x4);
    
    return new Vertex(pos: newpos)
    }
    */
    
    func toStlString() -> String {
        return "vertex " + self.pos.toStlString() + "\n"
    }
    
    func toAMFString() -> String {
        return "<vertex><coordinates>" + self.pos.toAMFString() + "</coordinates></vertex>\n"
    }
    
    func toString() -> String {
        return self.pos.toString()
    }
}

struct Plane {
    let normal : Vector
    let w : Double
    
    // `epsilon` is the tolerance used by `splitPolygon()` to decide if a
    // point is on the plane.
    static let epsilon = 1e-5
    
    init(normal: Vector, w: Double) {
        self.normal = normal
        self.w = w
    }
    
    // init Plane with 3 vectors
    init(a: Vector, b: Vector, c: Vector) {
        self.normal  = ((b - a).cross(c - a)).unit()
        self.w = self.normal.dot(a)
    }
    
    // init Plane with 3 vertices
    init(a: Vertex, b: Vertex, c: Vertex) {
        self.init(a: a.pos, b: b.pos, c: c.pos)
    }
    
    // init Plane with 2 Vectors, normal and point
    init(normal: Vector, point: Vector) {
        self.normal = normal.unit()
        self.w = point.dot(normal)
    }
    
    // init Plane from polygon
    init(poly: Polygon) {
        self.init(a: poly.vertices[0], b: poly.vertices[1], c: poly.vertices[2])
    }
    
    func flipped()->Plane {
        return Plane(normal: self.normal.negated(),w: -self.w)
    }

    
    func equals(plane: Plane) -> Bool {
        return self.normal.equals(plane.normal) && self.w == plane.w
    }
    
    /* transform: function(matrix4x4) {
    var ismirror = matrix4x4.isMirroring();
    // get two vectors in the plane:
    var r = this.normal.randomNonParallelVector();
    var u = this.normal.cross(r);
    var v = this.normal.cross(u);
    // get 3 points in the plane:
    var point1 = this.normal.times(this.w);
    var point2 = point1.plus(u);
    var point3 = point1.plus(v);
    // transform the points:
    point1 = point1.multiply4x4(matrix4x4);
    point2 = point2.multiply4x4(matrix4x4);
    point3 = point3.multiply4x4(matrix4x4);
    // and create a new plane from the transformed points:
    var newplane = CSG.Plane.fromVector3Ds(point1, point2, point3);
    if(ismirror) {
    // the transform is mirroring
    // We should mirror the plane:
    newplane = newplane.flipped();
    }
    return newplane;
    },
    */
    
    // Returns tuple:
    // .type:
    //   0: coplanar-front
    //   1: coplanar-back
    //   2: front
    //   3: back
    //   4: spanning
    // In case the polygon is spanning, returns:
    // .front: a Polygon of the front part, optional
    // .back: a Polygon of the back part, optional
    
    
    /*
    // returns CSG.Vector3D
    intersectWithLine: function(line3d) {
    return line3d.intersectWithPlane(this);
    },
    
    // intersection of two planes
    intersectWithPlane: function(plane) {
    return CSG.Line3D.fromPlanes(this, plane);
    },
    */
    
    func signedDistanceToPoint(point: Vector) -> Double {
        return self.normal.dot(point) - self.w;
    }
    
    func toString() -> String {
        return "[normal: " + self.normal.toString() + ", w: \(self.w)]"
    }
    
    func mirrorPoint(point: Vector) -> Vector {
        var distance = self.signedDistanceToPoint(point)
        var mirrored = point - self.normal.times(distance * 2.0)
        return mirrored
    }
    
}


struct Polygon {
    var vertices : [Vertex]
    let shared : Int
    let plane : Plane
    
    init(vertices : [Vertex], shared : Int, plane : Plane) {
        self.vertices = vertices
        self.shared = shared
        self.plane = plane
    }
    
    init(vertices: [Vertex], shared : Int) {
        self.vertices = vertices
        self.shared = shared
        self.plane = Plane(a: vertices[0],b: vertices[1],c: vertices[2])
    }
    
    // check whether the polygon is convex (it should be, otherwise we will get unexpected results)
    func checkIfConvex() {
        if verticesConvex(self.vertices, normal: self.plane.normal) {
            verticesConvex(self.vertices, normal: self.plane.normal)
            println("Not Convex polygon found!")
            //throw new Error("Not convex!")
        }
    }
    
    mutating func generateNormal() {
        let a = self.vertices[1].pos - self.vertices[0].pos
        let b = self.vertices[2].pos - self.vertices[0].pos
        
        let polyNormal = a.cross(b).unit()
        
        for var i = 0; i < self.vertices.count; i++ {
            self.vertices[i].normal = polyNormal
        }
    }
    
    // need to re consider
    func fliped() -> Polygon {
        return self
    }
    
    func toStlString() -> String {
        var result = ""
        if(self.vertices.count >= 3) // should be!
        {
            // STL requires triangular polygons. If our polygon has more vertices, create
            // multiple triangles:
            var firstVertexStl = self.vertices[0].toStlString()
            for var i = 0; i < self.vertices.count - 2; i++ {
                result += "facet normal " + self.plane.normal.toStlString() + "\nouter loop\n"
                result += firstVertexStl
                result += self.vertices[i + 1].toStlString()
                result += self.vertices[i + 2].toStlString()
                result += "endloop\nendfacet\n"
            }
        }
        return result
    }
    
    func toString() -> String {
        var result = "Polygon plane: " + self.plane.toString() + "\n"
        
        for vertex in self.vertices {
            result += "  " + vertex.toString() + "\n";
        }
        return result
    }
    
    func verticesConvex(vertices: [Vertex], normal: Vector) -> Bool {
        let numvertices = vertices.count
        if numvertices > 2 {
            var prevprevpos = vertices[numvertices - 2].pos
            var prevpos = vertices[numvertices - 1].pos
            for var i = 0; i < numvertices; i++ {
                let pos = vertices[i].pos
                if isConvexPoint(prevprevpos, point: prevpos, nextpoint: pos, normal: normal) {
                    return false
                }
                prevprevpos = prevpos
                prevpos = pos
            }
        }
        return true
    }
    
    func isConvexPoint(prevpoint: Vector, point: Vector, nextpoint: Vector, normal: Vector) -> Bool {
        let crossproduct = point - prevpoint.cross(nextpoint - point)
        let crossdotnormal = crossproduct.dot(normal)
        return (crossdotnormal >= 0)
    }
}







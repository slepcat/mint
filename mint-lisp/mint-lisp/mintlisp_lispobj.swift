//
//  mintlisp_lispobj.swift
//  mint-lisp
//
//  Created by NemuNeko on 2015/08/03.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

public class SExpr {
    
    public let uid : UInt
    
    init() {
        uid = UID.get.newID
    }
    
    init(uid: UInt) {
        self.uid = uid
    }
    
    func mirror_for_thread() -> SExpr {
        return SExpr(uid: uid)
    }
    
    func lookup_exp(uid:UInt) -> (conscell: SExpr, target: SExpr) {
        if self.uid == uid {
            return (MNull.errNull, self)
        } else {
            return (MNull.errNull, MNull.errNull)
        }
    }
    
    func isNull() -> Bool { return false }
    
    func eval(env: Env) -> SExpr {
        return self
    }
    
    public func str(indent:String, level: Int) -> String {
        return ""
    }
    
    public func _debug_string() -> String {
        return "_null_"
    }
}

public class Pair:SExpr {
    var car:SExpr
    var cdr:SExpr
    
    override init() {
        car = MNull()
        cdr = MNull()
        super.init()
    }
    
    init(car _car:SExpr) {
        car = _car
        cdr = MNull()
        super.init()
    }
    
    init(cdr _cdr:SExpr) {
        car = MNull()
        cdr = _cdr
        super.init()
    }
    
    init(car _car:SExpr, cdr _cdr:SExpr) {
        car = _car
        cdr = _cdr
        super.init()
    }
    
    private init(uid: UInt, car: SExpr, cdr: SExpr) {
        self.car = car
        self.cdr = cdr
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return Pair(uid: uid, car: car.mirror_for_thread(), cdr: cdr.mirror_for_thread())
    }
    
    override func lookup_exp(uid:UInt) -> (conscell: SExpr, target: SExpr) {
        
        if self.uid == uid {
            return (MNull.errNull, self)
        } else  {
            let resa = car.lookup_exp(uid)
            if resa.target.uid != MNull.errNull.uid {
                if resa.conscell.isNull() { return (self, resa.target) }
                return resa
            }
            
            let resd = cdr.lookup_exp(uid)
            
            if resd.target.uid != MNull.errNull.uid {
                if resd.conscell.isNull() { return (self, resd.target) }
                return resd
            }
            
            return (MNull.errNull, MNull.errNull)
            
        }
    }
    
    public override func str(indent: String, level:Int) -> String {
        
        var leveledIndent : String = ""
        for var i = 0; level > i; i++ {
            leveledIndent += indent
        }
        
        let res = str_list_of_exprs(self, indent: indent, level: level + 1 )
        
        var acc : String = ""
        
        for s in res {
            if s[s.startIndex] == "(" {
                if indent == "" {
                    acc += s
                } else {
                    acc += "\n" + leveledIndent + s
                }
            } else {
                if acc == "" {
                    acc += s
                } else {
                    acc += " " + s
                }
            }
        }
        
        return "(" + acc + ")"
    }
    
    private func str_list_of_exprs(_opds :SExpr, indent:String, level: Int) -> [String] {
        if let atom = _opds as? Atom {
            return [atom.str(indent, level: level)]
        } else {
            return tail_str_list_of_exprs(_opds, acc: [], indent: indent, level: level)
        }
    }
    
    private func tail_str_list_of_exprs(_opds :SExpr, var acc: [String], indent:String, level: Int) -> [String] {
        if let pair = _opds as? Pair {
            acc.append(pair.car.str(indent, level: level))
            return tail_str_list_of_exprs(pair.cdr, acc: acc, indent: indent, level: level)
        } else {
            return acc
        }
    }
    
    public override func _debug_string() -> String {
        return "(\(car._debug_string()) . \(cdr._debug_string()))"
    }
}

// Primitive Form Syntax

public class Form:SExpr {
    
    var category : String {
        get {return "special form"}
    }
    
    public func params_str() -> [String] {
        return []
    }
}

public class MDefine:Form {
    
    override func mirror_for_thread() -> SExpr {
        return MDefine(uid: uid)
    }
    
    override public func params_str() -> [String] {
        return ["symbol", "value"]
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "define"
    }
    
    public override func _debug_string() -> String {
        return "define"
    }
}

public class MQuote: Form {
    
    override func mirror_for_thread() -> SExpr {
        return MQuote(uid: uid)
    }
    
    override public func params_str() -> [String] {
        return ["value"]
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "quote"
    }
    
    public override func _debug_string() -> String {
        return "quote"
    }
}

public class MBegin:Form {
    
    override func mirror_for_thread() -> SExpr {
        return MBegin(uid: uid)
    }
    
    override public func params_str() -> [String] {
        return [".procs"]
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "begin"
    }
    
    public override func _debug_string() -> String {
        return "begin"
    }
}

public class Procedure:Form {
    
    public var params:SExpr
    var body:SExpr
    var initial_env:Env
    var rec_env: Env? = nil
    
    override var category : String {
        get {return "custom"}
    }
    
    init(_params: SExpr, body _body: SExpr, env _env: Env) {
        initial_env = _env
        params = _params
        body = _body
        
        super.init()
    }
    
    private init(uid: UInt, params: SExpr, body: SExpr, initial_env: Env, rec_env: Env?) {
        self.params = params
        self.body = body
        self.initial_env = initial_env
        self.rec_env = rec_env
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return Procedure(uid: uid, params: params.mirror_for_thread(), body: body.mirror_for_thread(), initial_env: initial_env.clone(), rec_env: rec_env?.clone())
    }
    
    func apply(env: Env, seq: [SExpr]) -> (exp: SExpr, env: Env) {
        
        let _params = delayed_list_of_args(self.params)
        
        if let _env = rec_env {
            for var i = 0; _params.count > i; i++ {
                if let sym = _params[i] as? MSymbol {
                    _env.set_variable(sym.key, val: seq[i])
                } else {
                    if !_params[i].isNull() || i != 0 {
                        print("syntax error: procedure. not symbol in params")
                        return (body, env)
                    }
                }
            }
        } else {
            if let new_env = initial_env.extended_env(_params, values: seq) {
                rec_env = new_env.clone()
            } else {
                return (body, env)
            }
        }
        
        return (body, rec_env!.clone())
    }
    
    // Generate array of atoms without evaluation for Evaluator.eval() method
    func delayed_list_of_args(_opds :SExpr) -> [SExpr] {
        if let atom = _opds as? Atom {
            return [atom]
        } else {
            return tail_delayed_list_of_values(_opds, acc: [])
        }
    }
    
    private func tail_delayed_list_of_values(_opds :SExpr, var acc: [SExpr]) -> [SExpr] {
        if let pair = _opds as? Pair {
            acc.append(pair.car)
            return tail_delayed_list_of_values(pair.cdr, acc: acc)
        } else {
            return acc
        }
    }
    
    override public func params_str() -> [String] {
        
        let _params = delayed_list_of_args(self.params)
        
        var acc : [String] = []
        
        for p in _params {
            acc += [p.str("", level: 0)]
        }
        return acc
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "proc: export error!"
    }
    
    public override func _debug_string() -> String {
        return "procedure"
    }
}

public class MLambda: Form {
    
    override func mirror_for_thread() -> SExpr {
        return MLambda(uid: uid)
    }
    
    func make_lambda(params: SExpr, body: SExpr) -> SExpr {
        return Pair(car: self, cdr: Pair(car: params, cdr: Pair(car: body)))
    }
    
    public override func params_str() -> [String] {
        return ["params", "body"]
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "lambda"
    }
    
    public override func _debug_string() -> String {
        return "lambda"
    }
}

public class MIf: Form {
    
    override func mirror_for_thread() -> SExpr {
        return MIf(uid: uid)
    }
    
    public override func params_str() -> [String] {
        return ["predic", "then", "else"]
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "if"
    }
    
    public override func _debug_string() -> String {
        return "if"
    }
}

public class MSet:Form {
    
    override func mirror_for_thread() -> SExpr {
        return MSet(uid: uid)
    }
    
    public override func params_str() -> [String] {
        return ["symbol", "value"]
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "set!"
    }
    
    public override func _debug_string() -> String {
        return "set!"
    }
}

// Atoms
// Symbol and Literals

public class Atom:SExpr {
    
}

public class MSymbol:Atom {
    var key : String
    
    init(_key: String) {
        key = _key
        super.init()
    }
    
    private init(uid: UInt, key: String) {
        self.key = key
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MSymbol(uid: uid, key: key)
    }
    
    override func eval(env: Env) -> SExpr {
        return env.lookup(key)
    }
    
    public override func str(indent: String, level:Int) -> String {
        return key
    }
    
    public override func _debug_string() -> String {
        return "Symbol:" + key
    }
}

public class Literal:Atom {
    
    override func eval(env: Env) -> SExpr {
        return self
    }
}

public class MInt: Literal {
    var value:Int
    
    init(_value: Int) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: Int) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MInt(uid: uid, value: value)
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "\(value)"
    }
    
    public override func _debug_string() -> String {
        return "Int:\(value)"
    }
}

public class MDouble: Literal {
    var value:Double
    
    init(_value: Double) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: Double) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MDouble(uid: uid, value: value)
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "\(value)"
    }
    
    public override func _debug_string() -> String {
        return "Double:\(value)"
    }
}

public class MStr: Literal {
    var value:String
    
    init(_value: String) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: String) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MStr(uid: uid, value: value)
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "\"" + value + "\""
    }
    
    public override func _debug_string() -> String {
        return "String:\"\(value)\""
    }
}

public class MChar: Literal {
    var value:Character
    
    init(_value: Character) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: Character) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MChar(uid: uid, value: value)
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "\(value)"
    }
    
    public override func _debug_string() -> String {
        return "Char:\(value)"
    }
}

public class MNull:Literal {
    
    override func mirror_for_thread() -> SExpr {
        return MNull(uid: uid)
    }
    
    // avoid consume uid. do not use as a member of s-expression.
    // cause identification problem for SExpr manipulation
    class var errNull:MNull {
        struct Static {
            static let singletonNull = MNull()
        }
        return Static.singletonNull
    }
    
    override func isNull() -> Bool {
        return true
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "null"
    }
    
    public override func _debug_string() -> String {
        return "_null_"
    }
}

public class MBool:Literal {
    var value:Bool
    
    init(_value: Bool) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: Bool) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MBool(uid: uid, value: value)
    }
    
    public override func str(indent: String, level:Int) -> String {
        return "\(value)"
    }
    
    public override func _debug_string() -> String {
        return "Bool:\(value)"
    }
}

public class MVector:Literal {
    var value:Vector
    
    init(_value: Vector) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: Vector) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MVector(uid: uid, value: value)
    }
    
    public override func str(indent: String, level: Int) -> String {
        return "(vec \(value.x) \(value.y) \(value.z))"
    }
    
    public override func _debug_string() -> String {
        return "Vector: [\(value.x), \(value.y), \(value.z)]"
    }
}

public class MVertex:Literal {
    var value:Vertex
    
    init(_value: Vertex) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: Vertex) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MVertex(uid: uid, value: value)
    }
    
    public override func str(indent: String, level: Int) -> String {
        
        var color = "(color"
        for c in value.color {
            color += " \(c)"
        }
        color += ")"
        
        return "(vex (vec \(value.pos.x) \(value.pos.y) \(value.pos.z)) (vec \(value.normal.x) \(value.normal.y) \(value.normal.z)) " + color + ")"
    }
    
    public override func _debug_string() -> String {
        
        var color = "["
        for c in value.color {
            color += " \(c)"
        }
        color += "]"
        
        return "Vertex: [\(value.pos.x), \(value.pos.y), \(value.pos.z)] [\(value.normal.x), \(value.normal.y), \(value.normal.z)] " + color
    }
}

public class MColor : Literal {
    var value = [Float](count: 3 ,repeatedValue: 0.5)
    
    init(_value: [Float]) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: [Float]) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MColor(uid: uid, value: value)
    }
    
    public override func str(indent: String, level: Int) -> String {
        
        var color = "(color"
        for c in value {
            color += " \(c)"
        }
        color += ")"
        
        return color
    }
    
    
    public override func _debug_string() -> String {
        
        var color = "Color: ["
        for c in value {
            color += "\(c), "
        }
        
        var chr = color.characters
        chr.removeLast()
        chr.removeLast()
        color = String(chr)
        color += "]"
        
        return color
    }
}

public class MPlane : Literal {
    var value:Plane
    
    init(_value: Plane) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: Plane) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MPlane(uid: uid, value: value)
    }
    
    public override func str(indent: String, level: Int) -> String {
        
        return "(plane (vec \(value.normal.x) \(value.normal.y) \(value.normal.z)) \(value.w))"
    }
    
    
    public override func _debug_string() -> String {
        
        return "Plane: [\(value.normal.x), \(value.normal.y), \(value.normal.z)], \(value.w) "
    }
}

public class MPolygon : Literal {
    var value : Polygon
    
    init(_value: Polygon) {
        value = _value
        super.init()
    }
    
    private init(uid: UInt, value: Polygon) {
        self.value = value
        super.init(uid: uid)
    }
    
    override func mirror_for_thread() -> SExpr {
        return MPolygon(uid: uid, value: value)
    }
    
    public override func str(indent: String, level: Int) -> String {
        
        var acc = "(polygon "
        
        for vex in value.vertices {
            let mvex = MVertex(_value: vex)
            acc += mvex.description + " "
        }
        
        let mpln = MPlane(_value: value.plane)
        acc += mpln.description + ")"
        
        return acc
    }
    
    public override func _debug_string() -> String {
        
        var acc = "Polygon: "
        
        for vex in value.vertices {
            acc += "[\(vex.pos.x), \(vex.pos.y), \(vex.pos.z)]" + " "
        }
        
        acc += "normal \(value.plane.normal.x) \(value.plane.normal.y) \(value.plane.normal.z) w \(value.plane.w)"
        
        return acc
    }
}

public class MintIO {
    
}

public class IOMesh: MintIO {
    public var mesh: [Double]
    public var normal: [Double]
    public var color: [Float]
    public var alpha: [Float]
    
    init(mesh:[Double], normal:[Double], color:[Float], alpha:[Float]) {
        self.mesh = mesh
        self.normal = normal
        self.color = color
        self.alpha = alpha
    }
    
    public func str(indent: String, level: Int) -> String {
        return "<<#IOMesh> \(mesh), \(normal), \(color)>"
    }
    
    public func _debug_string() -> String {
        return "<<#IOMesh> \(mesh), \(normal), \(color)>"
    }
}

public class IOErr: MintIO {
    public var err : String
    public var uid_err : UInt
    
    init(err: String, uid: UInt) {
        self.err = err
        uid_err = uid
    }
    
    public func str(indent: String, level: Int) -> String {
        return "<<#IOErr> \(err), uid: \(uid_err)>"
    }
    
    public func _debug_string() -> String {
        return "<<#IOErr> \(err), uid: \(uid_err)>"
    }
}

extension Literal : CustomStringConvertible {
    public var description: String {
        return self.str("", level: 0)
    }
}

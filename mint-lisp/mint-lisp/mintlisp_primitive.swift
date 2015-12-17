//
//  mintlisp_primitive.swift
//  mint-lisp
//
//  Created by NemuNeko on 2015/08/07.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

class Primitive:Form {
    
    override var category : String {
        get {return "lisp"}
    }
    
    func apply(var args: [SExpr]) -> SExpr {
        if args.count == 0 {
            return MNull()
        } else {
            let head = args.removeAtIndex(0)
            return foldl(proc, acc: head, operands: args)
        }
    }
    
    func proc(a: SExpr, b: SExpr) -> SExpr {
        return MNull()
    }
    
    override func params_str() -> [String] {
        return [".a"]
    }
}

class Plus:Primitive {
    
    override var category : String {
        get {return "math"}
    }
    
    override func proc(a: SExpr, b: SExpr) -> SExpr {
        switch a {
        case let num as MInt:
            switch b {
            case let num2 as MDouble:
                return MDouble(_value: Double(num.value) + num2.value)
            case let num2 as MInt:
                return MInt(_value: num.value + num2.value)
            default:
                return MNull()
            }
        case let num as MDouble:
            
            switch b {
            case let num2 as MDouble:
                return MDouble(_value: num.value + num2.value)
            case let num2 as MInt:
                return MDouble(_value: num.value + Double(num2.value))
            default:
                return MNull()
            }
        case let str as MStr:
            switch b {
            case let str2 as MStr:
                return MStr(_value: str.value + str2.value)
            case let chr as MChar:
                return MStr(_value: str.value + String(chr.value))
            default:
                return MNull()
                
            }
        case let chr as MChar:
            switch b {
            case let str as MStr:
                return MStr(_value: String(chr.value) + str.value)
            case let chr2 as MChar:
                return MStr(_value: String(chr.value) + String(chr2.value))
            default:
                return MNull()
            }
        default:
            return MNull()
            
        }
    }
}

class Minus:Primitive {
    
    override var category : String {
        get {return "math"}
    }
    
    override func proc(a: SExpr, b: SExpr) -> SExpr {
        switch a {
        case let num as MInt:
            switch b {
            case let num2 as MDouble:
                return MDouble(_value: Double(num.value) - num2.value)
            case let num2 as MInt:
                return MInt(_value: num.value - num2.value)
            default:
                return MNull()
            }
        case let num as MDouble:
            
            switch b {
            case let num2 as MDouble:
                return MDouble(_value: num.value - num2.value)
            case let num2 as MInt:
                return MDouble(_value: num.value - Double(num2.value))
            default:
                return MNull()
            }
        default:
            return MNull()
            
        }
    }
}

class Multiply:Primitive {
    
    override var category : String {
        get {return "math"}
    }
    
    override func proc(a: SExpr, b: SExpr) -> SExpr {
        switch a {
        case let num as MInt:
            switch b {
            case let num2 as MDouble:
                return MDouble(_value: Double(num.value) * num2.value)
            case let num2 as MInt:
                return MInt(_value: num.value * num2.value)
            default:
                return MNull()
            }
        case let num as MDouble:
            
            switch b {
            case let num2 as MDouble:
                return MDouble(_value: num.value * num2.value)
            case let num2 as MInt:
                return MDouble(_value: num.value * Double(num2.value))
            default:
                return MNull()
            }
        default:
            return MNull()
            
        }
    }
}

class Divide:Primitive {
    
    override var category : String {
        get {return "math"}
    }
    
    override func proc(a: SExpr, b: SExpr) -> SExpr {
        switch a {
        case let num as MInt:
            switch b {
            case let num2 as MDouble:
                return MDouble(_value: Double(num.value) / num2.value)
            case let num2 as MInt:
                return MDouble(_value: Double(num.value) / Double(num2.value))
            default:
                return MNull()
            }
        case let num as MDouble:
            
            switch b {
            case let num2 as MDouble:
                return MDouble(_value: num.value / num2.value)
            case let num2 as MInt:
                return MDouble(_value: num.value / Double(num2.value))
            default:
                return MNull()
            }
        default:
            return MNull()
            
        }
    }
}

class isEqual:Primitive {
    
    override var category : String {
        get {return "math"}
    }
    
    override func apply(var args: [SExpr]) -> SExpr {
        if args.count == 0 {
            return MNull()
        } else {
            let head = args.removeAtIndex(0)
            let result = foldl(proc, acc: head, operands: args)
            if let res = result as? MBool {
                return res
            } else if let _ = result as? MNull {
                print("Cannot apply \"-\" to non-number objects.")
                return MNull()
            } else {
                return MBool(_value: true)
            }
        }
    }
    
    override func proc(a: SExpr, b: SExpr) -> SExpr {
        switch a {
        case let num as MInt:
            switch b {
            case let num2 as MDouble:
                return Double(num.value) == num2.value ? a : MBool(_value: false)
            case let num2 as MInt:
                return Double(num.value) == Double(num2.value) ? a : MBool(_value: false)
            default:
                return MNull()
            }
        case let num as MDouble:
            
            switch b {
            case let num2 as MDouble:
                return num.value == num2.value ? a : MBool(_value: false)
            case let num2 as MInt:
                return num.value == Double(num2.value) ? a : MBool(_value: false)
            default:
                return MNull()
            }
        default:
            return MNull()
            
        }
    }
}

class CastDouble : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        
        if args.count == 1 {
            switch args[0] {
            case let num as MInt:
                return MDouble(_value: Double(num.value))
            case let num as MDouble:
                return num
            default:
                print("cast-doulbe take only number literal", terminator: "\n")
                return MNull()
            }
        }
        print("cast-double take only 1 element", terminator: "\n")
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["a"]
    }
}

///// conscell procedures /////

class Cons : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 2 {
            
            return Pair(car: args[0], cdr: args[1])
        }
        
        print("cons must take 2 element", terminator: "\n")
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["elem", "list"]
    }
}

class Car : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.car
            } else {
                print("car take only Pair", terminator: "\n")
            }
        } else {
            print("car take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Cdr : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.cdr
            } else {
                print("cdr take only Pair", terminator: "\n")
            }
        } else {
            print("cdr take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Caar : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.caar
            } else {
                print("caar take only Pair", terminator: "\n")
            }
        } else {
            print("caar take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Cadr : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.cadr
            } else {
                print("cadr take only Pair", terminator: "\n")
            }
        } else {
            print("cadr take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Cddr : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.cddr
            } else {
                print("cddr take only Pair", terminator: "\n")
            }
        } else {
            print("cddr take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Cdar : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.cdar
            } else {
                print("cdar take only Pair", terminator: "\n")
            }
        } else {
            print("cdar take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Caaar : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.caaar
            } else {
                print("caaar take only Pair", terminator: "\n")
            }
        } else {
            print("caaar take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Caadr : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.caadr
            } else {
                print("caadr take only Pair", terminator: "\n")
            }
        } else {
            print("caadr take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Caddr : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.caddr
            } else {
                print("caddr take only Pair", terminator: "\n")
            }
        } else {
            print("caddr take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Cdddr : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.cdddr
            } else {
                print("cdddr take only Pair", terminator: "\n")
            }
        } else {
            print("cdddr take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Cdaar : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.cdaar
            } else {
                print("cdaar take only Pair", terminator: "\n")
            }
        } else {
            print("cdaar take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Cadar : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.cadar
            } else {
                print("cadar take only Pair", terminator: "\n")
            }
        } else {
            print("cadar take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Cdadr : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.cdadr
            } else {
                print("cdadr take only Pair", terminator: "\n")
            }
        } else {
            print("cdadr take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

class Cddar : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            if let pair = args.first as? Pair {
                return pair.cddar
            } else {
                print("cddar take only Pair", terminator: "\n")
            }
        } else {
            print("cddar take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["list"]
    }
}

///// IO /////

class Print : Primitive {
    override func apply(args: [SExpr]) -> SExpr {
        if args.count == 1 {
            print(args[0], terminator: "\n")
        } else {
            print("print take only 1 argument", terminator: "\n")
        }
        return MNull()
    }
    
    override func params_str() -> [String] {
        return ["a"]
    }
}

class Quit : Primitive {
    // dummy, for real quit process, see main.swift
    override func apply(args: [SExpr]) -> SExpr {
        print("byby", terminator: "\n")
        return MNull()
    }
}
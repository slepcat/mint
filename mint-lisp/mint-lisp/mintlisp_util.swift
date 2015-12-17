//
//  mintlisp_util.swift
//  mint-lisp
//
//  Created by NemuNeko on 2015/08/01.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation


func foldl<T>(_func: (T, T) -> T, var acc: T, var operands: [T]) -> T{
    if operands.count == 0 {
        return acc
    } else {
        let head = operands.removeAtIndex(0)
        acc = _func(acc, head)
        
        return foldl(_func, acc: acc, operands: operands)
    }
}

func map<T, U>(_func: (T) -> U, operands: [T]) -> [U] {
    return tail_map(_func, acc: [], operands: operands)
}

private func tail_map<T, U>(_func: (T) -> U, var acc: [U], var operands: [T]) -> [U] {
    if operands.count == 0 {
        return acc
    } else {
        let head = operands.removeAtIndex(0)
        acc.append(_func(head))
        return tail_map(_func,acc: acc, operands: operands)
    }
}

func flatMap<T, U>(operands: [T],f: (T) -> [U]) -> [U] {
    let nestedList = tail_map(f, acc: [], operands: operands)
    return flatten(nestedList)
}

private func flatten<U>(nested:[[U]]) -> [U] {
    return tail_flatten(nested, acc: [])
}

private func tail_flatten<U>(var nested:[[U]], acc:[U]) -> [U] {
    if nested.count == 0 {
        return acc
    } else {
        let head = nested.removeAtIndex(0)
        let newacc = head + acc
        return tail_flatten(nested, acc: newacc)
    }
}

func _and(a :Bool, b: Bool) -> Bool {
    return (a && b)
}

func _or(a :Bool, b: Bool) -> Bool {
    return (a || b)
}


///// Utilities /////

public func delayed_list_of_values(_opds :SExpr) -> [SExpr] {
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

public func list_from_array(array: [SExpr]) -> SExpr {
    return tail_list_from_array(array, acc: MNull())
}

private func tail_list_from_array(var array: [SExpr], var acc: SExpr) -> SExpr {
    if array.count == 0 {
        return acc
    } else {
        let exp = array.removeLast()
        acc = Pair(car: exp, cdr: acc)
        return tail_list_from_array(array, acc: acc)
    }
}

///// numeric //////

func cast2double(exp: SExpr) -> Double? {
    switch exp {
    case let num as MInt:
        return Double(num.value)
    case let num as MDouble:
        return num.value
    default:
        print("cast-doulbe take only number literal", terminator: "\n")
        return nil
    }
}

// unique id generator.
// UID factory: we can request a unique ID through UID.get.newID
// Singleton

class UID {
    private var count:UInt = 0
    private init(){}
    
    var newID: UInt {
        return count++
    }
    
    class var get: UID {
        struct Static{
            static let idFactory = UID()
        }
        return Static.idFactory
    }
}

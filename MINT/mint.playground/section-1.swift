// Playground - noun: a place where people can play

import Foundation
import Cocoa


struct ValWrap { var value: Int = 0 }
class RefWrap { var value: Int = 0 }

//値の値渡し
func swapAndEdit(var left: ValWrap, var right: ValWrap) {
    var tmp = left
    left = right
    right = tmp
    tmp.value *= 100
}

//参照の値渡し
func swapAndEdit(var left: RefWrap, var right: RefWrap) {
    var tmp = left
    left = right
    right = tmp
    tmp.value *= 100
}

func swapAndEdit(inout left: ValWrap, inout right: ValWrap ) {
    var tmp = left
    left = right
    right = tmp
    tmp.value *= 100
}

//参照の参照渡し
func swapAndEdit(inout left: RefWrap, inout right: RefWrap) {
    var tmp = left
    left = right
    right = tmp
    tmp.value *= 100
}

if true {
    println("値の値渡し")
    var left = ValWrap()
    left.value = 1
    var right = ValWrap()
    right.value = 2
    swapAndEdit(left, right)
    println("\(left.value), \(right.value)")
}

if true {
    println("参照の値渡し")
    var left = RefWrap()
    left.value = 1
    var right = RefWrap()
    right.value = 2
    swapAndEdit(left, right)
    println("\(left.value), \(right.value)")
}

if true {
    println("値の参照渡し")
    var left = ValWrap()
    left.value = 1
    var right = ValWrap()
    right.value = 2
    swapAndEdit(&left, &right)
    println("\(left.value), \(right.value)")
}

if true {
    println("参照の参照渡し")
    var left = RefWrap()
    left.value = 1
    var right = RefWrap()
    right.value = 2
    swapAndEdit(&left, &right)
    println("\(left.value), \(right.value)")
}

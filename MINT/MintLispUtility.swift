//
//  MintLispUtility.swift
//  mint
//
//  Created by NemuNeko on 2016/01/19.
//  Copyright © 2016年 Taizo A. All rights reserved.
//

import Foundation

class MintPosUnwrapper {
    
    fileprivate var tree : Pair? = nil
    fileprivate var positions : [(uid: UInt, pos:NSPoint)] = []
    
    var unwrapped : SExpr {
        get {
            if let pair = tree {
                return pair
            } else {
                return MNull()
            }
        }
    }
    
    var leafpos : LeafPositions {
        get {
            return LeafPositions(positions: positions)
        }
    }
    
    init(expr: Pair) {
        var pos : [(uid: UInt, pos: NSPoint?)] = []
        
        tree = rec_unwrap_pos(expr, pos_acc: &pos)
        positions = repair_position(tree!, pos_acc: pos)
    }
    
    fileprivate func rec_unwrap_pos(_ _head: Pair, pos_acc: inout [(uid: UInt, pos: NSPoint?)]) -> Pair {
        var pos_x : Double? = nil
        var pos_y : Double? = nil
        var head = _head
        
        // check if the s-expression is wrapped by "_pos_" expression
        // if yes, unwrap and get position
        if let pos = head.car as? MSymbol {
            if pos.key == "_pos_" {
                
                switch head.cadr {
                case let x as MDouble:
                    pos_x = x.value
                case let x as MInt:
                    pos_x = Double(x.value)
                default:
                    break
                }
                
                switch head.caddr {
                case let y as MDouble:
                    pos_y = y.value
                case let y as MInt:
                    pos_y = Double(y.value)
                default:
                    break
                }
                
                if let leaf = head.cadddr as? Pair {
                    head = leaf
                }
            }
        }
        
        if let x = pos_x, let y = pos_y {
            pos_acc.append((head.uid, NSPoint(x: x, y: y)))
        } else {
            pos_acc.append((head.uid, nil))
        }
        
        let opds = delayed_list_of_values(head)
        
        for op in opds {
            if let pair = op as? Pair {
                
                if let parent = head.lookup_exp(pair.uid).conscell as? Pair {
                    parent.car = rec_unwrap_pos(pair, pos_acc: &pos_acc)
                }
            }
        }
        
        return head
    }
    
    fileprivate func repair_position(_ tree: Pair, pos_acc: [(uid: UInt, pos: NSPoint?)]) -> [(uid: UInt, pos: NSPoint)] {
        
        let rel_pos : [[UInt]] = relative_pos(tree)
        
        var result : [(uid: UInt, pos:NSPoint)] = []
        
        for depth in stride(from: 0, to:rel_pos.count, by:1) {
            for num in stride(from: 0, to:rel_pos[depth].count, by:1) {
                
                if let pos = get_pos(positions: pos_acc, uid: rel_pos[depth][num]) {
                    
                    result.append((rel_pos[depth][num], pos))
                } else {
                    
                    result.append((rel_pos[depth][num], NSPoint(x: 140.0 * Double(1 + depth), y: 90.0 * Double(1 + num))))
                }
            }
        }
        
        return result
    }
    
    fileprivate func relative_pos(_ tree: Pair) -> [[UInt]] {
        
        var acc_pos : [[UInt]] = []
        
        // add head leaf
        acc_pos.append([tree.uid])
        rec_rel_pos(tree: tree, rel_pos: &acc_pos, depth: 1)
        
        return acc_pos
    }
    
    fileprivate func rec_rel_pos(tree: Pair, rel_pos: inout [[UInt]], depth: Int){
        let ops = delayed_list_of_values(tree)
        
        for op in ops {
            if let pair = op as? Pair {
                if rel_pos.count <= depth {
                    rel_pos.append([pair.uid])
                } else {
                    rel_pos[depth].append(pair.uid)
                }
                rec_rel_pos(tree: pair, rel_pos: &rel_pos, depth: depth + 1)
            }
        }
    }
    
    fileprivate func get_pos(positions: [(uid: UInt, pos: NSPoint?)], uid: UInt) -> NSPoint? {
        for pos in positions {
            if pos.uid == uid {
                return pos.pos
            }
        }
        
        return nil
    }
}

struct LeafPositions {
    var positions : [(uid: UInt, pos: NSPoint)] = []
    
    func get_pos(_ uid: UInt) -> NSPoint {
        for pos in positions {
            if pos.uid == uid {
                return pos.pos
            }
        }
        
        return NSPoint(x: 0, y: 0)
    }
}

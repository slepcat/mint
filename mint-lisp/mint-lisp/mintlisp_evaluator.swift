//
//  mintlisp_evaluator.swift
//  mint-lisp
//
//  Created by NemuNeko on 2015/08/19.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

class Evaluator {
    
    private var callstack : [(exp:SExpr, seq:[SExpr], pc:Int, env:Env)] = []
    
    private func push(a:(exp:SExpr, seq:[SExpr], pc:Int, env:Env)) {
        callstack.append(a)
    }
    
    private func pop() -> (exp:SExpr, seq:[SExpr], pc:Int, env:Env)? {
        if callstack.count > 0 {
            return callstack.removeLast()
        }
        return nil
    }
    
    func eval(expr: SExpr, gl_env:Env) -> SExpr {
        var cf : (exp:SExpr, seq:[SExpr], pc:Int, env:Env) = (expr, delayed_list_of_values(expr), 0, gl_env)
        
        while true {
            
            var isRet = false
            var res : SExpr = MNull()
            
            if let _ = cf.exp as? Atom {
                if let literal = cf.exp as? Literal {
                    res = literal
                    isRet = true
                } else if let symbol = cf.exp as? MSymbol {
                    res = symbol.eval(cf.env)
                    isRet = true
                }
            } else if let pair = cf.exp as? Pair {
                
                if let _ = pair.car as? MQuote {
                    if cf.seq.count == 2 {
                        res = cf.seq[1]
                        isRet = true
                    } else {
                        print("syntax error: quote take 1 arg > " + cf.exp._debug_string(), terminator: "\n")
                        isRet = true
                    }
                    
                } else if let _ = pair.car as? MSet {
                    
                    if cf.pc == 0 {
                        
                        if cf.seq.count == 3 {
                            // eval definition value
                            cf.pc = 2
                            push(cf)
                            cf = (cf.seq[2], delayed_list_of_values(cf.seq[2]), 0, cf.env)
                            continue
                            
                        } else {
                            print("syntax error: define take 2 args > " + cf.exp._debug_string(), terminator: "\n")
                            isRet = true
                        }
                        
                    } else {
                    
                        if let symbol = cf.seq[1] as? MSymbol {
                            if !cf.env.set_variable(symbol.key, val: cf.seq[2]) {
                                print("failed to bind: undefined varialble identifier > " + symbol._debug_string(), terminator: "\n")
                            } else {
                                print(cf.seq[2]._debug_string() + " is set to " + symbol._debug_string(), terminator: "\n")
                            }
                        } else {
                            print("failed to bind: not symbol > " + cf.seq[1]._debug_string(), terminator: "\n")
                        }
                        isRet = true
                    }
                    
                } else if let _ = pair.car as? MDefine {
                    
                    if cf.pc == 0 {
                        
                        if cf.seq.count == 3 {
                            // if param is (f x) style
                            if let _var = cf.seq[1] as? Pair {
                                
                                // set 'f' to seq[1] as symbol
                                cf.seq[1] = _var.car
                                
                                // make lambda for f
                                cf.seq[2] = MLambda().make_lambda(_var.cdr, body: cf.seq[2])
                            }
                            
                            // eval definition value
                            cf.pc = 2
                            push(cf)
                            cf = (cf.seq[2], delayed_list_of_values(cf.seq[2]), 0, cf.env)
                            continue
                            
                        } else {
                            print("syntax error: define take 2 args > " + cf.exp._debug_string(), terminator: "\n")
                            isRet = true
                        }
                        
                    } else {
                        if let symbol = cf.seq[1] as? MSymbol {
                            if !cf.env.define_variable_force(symbol.key, val: cf.seq[2]) {// overwrite allowed
                                print("failed to bind: used varialble identifier > " + symbol._debug_string(), terminator: "\n")
                            } else {
                                print(cf.seq[2]._debug_string() + " is defined as " + symbol._debug_string(), terminator: "\n")
                            }
                        } else {
                            print("failed to bind: not symbol > " + cf.seq[1]._debug_string(), terminator: "\n")
                        }
                        isRet = true
                    }
                    
                } else if let _ = pair.car as? MIf {
                    
                    if cf.pc == 0 {
                        if (cf.seq.count == 4) || (cf.seq.count == 3) {
                            // eval predicate
                            cf.pc = 1
                            push(cf)
                            cf = (cf.seq[1], delayed_list_of_values(cf.seq[1]), 0, cf.env)
                            continue
                        } else {
                            print("syntax error: if take 2 or 3 exps > " + cf.exp._debug_string(), terminator: "\n")
                            isRet = true
                        }
                    } else {
                        if let _bool = cf.seq[1] as? MBool {
                            
                            if !_bool.value {
                                cf = (cf.seq[3], delayed_list_of_values(cf.seq[3]), 0, cf.env)
                                continue
                            }
                        }
                        cf = (cf.seq[2], delayed_list_of_values(cf.seq[2]), 0, cf.env)
                        continue
                    }
                    
                } else if let _ = pair.car as? MLambda {
                    if cf.seq.count == 3 {
                        res = Procedure(_params: cf.seq[1], body: cf.seq[2], env: cf.env)
                    } else {
                        print("syntax error: lambda take 2 args > " + cf.exp._debug_string(), terminator: "\n")
                    }
                    isRet = true
                    
                } else if let _ = pair.car as? MBegin {
                    
                    if (cf.seq.count > cf.pc) && (cf.seq.count > 1) {
                        
                        if cf.pc == 0 {
                            cf.pc++
                        }
                        
                        push(cf)
                        cf = (cf.seq[cf.pc], delayed_list_of_values(cf.seq[cf.pc]), 0, cf.env)
                        continue
                        
                    } else {
                        if let result = cf.seq.last {
                            res = result
                        } else {
                            print("syntax error: begins > " + cf.exp._debug_string(), terminator: "\n")
                        }
                        isRet = true
                    }
                    
                } else if let _ = pair.car as? Display {
                    
                    if (cf.seq.count > cf.pc) && (cf.seq.count > 1) {
                        
                        if cf.pc == 0 {
                            cf.pc++
                        }
                        
                        push(cf)
                        cf = (cf.seq[cf.pc], delayed_list_of_values(cf.seq[cf.pc]), 0, cf.env)
                        continue
                        
                    } else {
                        if let disp = cf.seq.first as? Primitive {
                            
                            res = disp.apply(tail(cf.seq))
                            isRet = true
                            
                        } else {
                            print("syntax error: not a procedure > " + cf.exp._debug_string(), terminator: "\n")
                            isRet = true
                        }
                    }
                } else {
                
                    if cf.seq.count > cf.pc {
                        
                        push(cf)
                        cf = (cf.seq[cf.pc], delayed_list_of_values(cf.seq[cf.pc]), 0, cf.env)
                        continue
                        
                    } else {
                        if let proc_prim = cf.seq.first as? Primitive {
                            
                            res = proc_prim.apply(tail(cf.seq))
                            isRet = true
                            
                        } else if let proc = cf.seq.first as? Procedure {
                            
                            let result = proc.apply(cf.env, seq: tail(cf.seq))
                            cf = (result.exp, delayed_list_of_values(result.exp), 0, result.env)
                            
                        } else {
                            print("syntax error: not a procedure > " + cf.exp._debug_string(), terminator: "\n")
                            isRet = true
                        }
                    }
                }
            }
            
            // return result to the frame of top of stack
            if isRet {
                if let nf = pop() {
                    cf = nf
                    cf.seq[cf.pc] = res
                    cf.pc++
                    continue
                } else {
                    // if there is no more frame in the stack, return result
                    return res
                }
            }
            
        }
    }
    
    private func delayed_list_of_values(_opds :SExpr) -> [SExpr] {
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
    
    private func tail(var seq: [SExpr]) -> [SExpr] {
        if seq.count > 0 {
            seq.removeAtIndex(0)
            return seq
        } else {
            return []
        }
    }
}
//
//  mintlisp_listops.swift
//  mint-lisp
//
//  Created by NemuNeko on 2015/08/17.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

extension Pair {
    // cXXr
    // (([a] . b) . c)
    var caar:SExpr {
        if let pair2 = car as? Pair {
            return pair2.car
        }
        return MNull()
    }
    
    // (a . (b . [c]))
    var cddr:SExpr {
        if let pair2 = cdr as? Pair {
            return pair2.cdr
        }
        return MNull()
    }
    
    // (a . ([b] . c))
    var cadr:SExpr {
        if let pair2 = cdr as? Pair {
            return pair2.car
        }
        return MNull()
    }
    
    // ((a . [b]) . c)
    var cdar:SExpr {
        if let pair2 = car as? Pair {
            return pair2.cdr
        }
        return MNull()
    }
    
    // cXXXr
    // (([a] . b) . c) . d)
    var caaar:SExpr {
        if let pair3 = caar as? Pair {
            return pair3.car
        }
        return MNull()
    }
    
    // ((a . [b]) . c) . d)
    var cdaar:SExpr {
        if let pair3 = caar as? Pair {
            return pair3.cdr
        }
        return MNull()
    }
    
    // (a . (b . ([c] . d)))
    var caddr:SExpr {
        if let pair3 = cddr as? Pair {
            return pair3.car
        }
        return MNull()
    }
    
    // (a . (b . (c . [d])))
    var cdddr:SExpr {
        if let pair3 = cddr as? Pair {
            return pair3.cdr
        }
        return MNull()
    }
    
    // (a . (([b] . c) . d))
    var caadr:SExpr {
        if let pair3 = cadr as? Pair {
            return pair3.car
        }
        return MNull()
    }
    
    // (a . ((b . [c]) . d))
    var cdadr:SExpr {
        if let pair3 = cadr as? Pair {
            return pair3.cdr
        }
        return MNull()
    }
    
    // ((a . ([b] . c)) . d)
    var cadar:SExpr {
        if let pair2 = cdar as? Pair {
            return pair2.car
        }
        return MNull()
    }
    
    // ((a . (b . [c])) . d)
    var cddar:SExpr {
        if let pair2 = cdar as? Pair {
            return pair2.cdr
        }
        return MNull()
    }
    
    // (a . (b . (c . ([d] . e))))
    var cadddr:SExpr {
        if let pair4 = cdddr as? Pair {
            return pair4.car
        }
        return MNull()
    }
    
    
    // (a . (b . (c . (d . [e]))))
    var cddddr:SExpr {
        if let pair4 = cdddr as? Pair {
            return pair4.cdr
        }
        return MNull()
    }
}
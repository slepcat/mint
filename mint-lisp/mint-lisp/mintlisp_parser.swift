//
//  mintlisp_parser.swift
//  mint-lisp
//
//  Created by NemuNeko on 2015/08/13.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Foundation

enum LispToken {
    case LParentheses           //(
    case RParentheses           //)
    case Symbol(String)
    case Boolean(Bool)
    case LispStr(String)
    case LispChr(Character)
    case LispInt(Int)
    case LispDouble(Double)
    case LispNull
    case VectorParentheses      //#(
    case Quote                  //’
    case BackQuate              //`
    case Comma                  //,
    case CommaAt                //,@
    case Dot                    //.
}

extension LispToken : CustomStringConvertible {
    var description: String {
        switch self {
        case .LParentheses:
            return "("
        case .RParentheses:
            return ")"
        case let .Symbol(str):
            return str
        case let .Boolean(_bool):
            if _bool {
                return "#t"
            } else {
                return "#f"
            }
        case let .LispStr(str):
            return str
        case let .LispChr(chr):
            return String(chr)
        case let .LispInt(num):
            return "\(num)"
        case let .LispDouble(num):
            return "\(num)"
        case .LispNull:
            return "null"
        case .VectorParentheses:
            return "#("
        case .Quote:
            return "’"
        case .BackQuate:
            return "`"
        case .Comma:
            return ","
        case .CommaAt:
            return ",@"
        case .Dot:
            return "."
        }
    }
}

extension LispToken {
    var isLParentheses:Bool {
        switch self {
        case .LParentheses:
            return true
        default:
            return false
        }
    }
    
    var isRParentheses:Bool {
        switch self {
        case .RParentheses:
            return true
        default:
            return false
        }
    }
    
    var expr:SExpr {
        switch self {
        case .LParentheses:
            return Pair()
        case .RParentheses:
            return MNull()
        case let .LispInt(num):
            return MInt(_value: num)
        case let .LispDouble(num):
            return MDouble(_value: num)
        case let .LispStr(str):
            return MStr(_value: str)
        case let .LispChr(chr):
            return MChar(_value: chr)
        case .LispNull:
            return MNull()
        case let .Symbol(symbol):
            
            switch symbol {
            case "set!":
                return MSet()
            case "define":
                return MDefine()
            case "lambda":
                return MLambda()
            case "if":
                return MIf()
            case "quote":
                return MQuote()
            case "begin":
                return MBegin()
            case "display":
                return Display()
            default:
                return MSymbol(_key: symbol)
            }
        case let .Boolean(bool):
            return MBool(_value: bool)
        default:
            print("Unsupported token type: \(self)")
            return MNull()
        }
    }
}

// Parser Combinator
// Based on following link:
// http://qiita.com/Ushio@github/items/23b4f9e11fbff2a8e981
// License: BSD

typealias SingleTokenizer = Comb<Character, LispToken>.Parser

struct Comb<Token, Result> {
    typealias Parser = [Token] -> [(Result, [Token])]
}

func pure<Token, Result>(result: Result) -> Comb<Token, Result>.Parser {
    return { input in return [(result, input)] }
}

func zero<Token, Result>() -> Comb<Token, Result>.Parser {
    return { input in return [] }
}

func consumer<Token>() -> Comb<Token, Token>.Parser {
    return { (var input:[Token]) in
        if input.count == 0 {
            return []
        } else {
            let head = input.removeAtIndex(0)
            return [(head, input)]
        }
    }
}

func unconsume<Token>() -> Comb<Token, Token>.Parser {
    return { (input:[Token]) in
        if let head = input.first {
            return [(head, input)]
        }
        return []
    }
}

func bind<Token, T, U>(parser: Comb<Token, T>.Parser, factory: T -> Comb<Token, U>.Parser) -> Comb<Token, U>.Parser {
    return { input in
        let res = parser(input)
        return flatMap(res) {(result, tail) in
            let parser = factory(result)
            return parser(tail)
        }
    }
}

func satisfy<Token>(condition: Token -> Bool) -> Comb<Token, Token>.Parser {
    return bind(consumer()) { r in
        if condition(r) {
            return pure(r)
        }
        return zero()
    }
}

func predict<Token>(condition: Token -> Bool) -> Comb<Token, Token>.Parser {
    return bind(unconsume()) { r in
        if condition(r) {
            return pure(r)
        }
        return zero()
    }
}

func token<Token :Equatable>(t: Token) -> Comb<Token, Token>.Parser {
    return satisfy { $0 == t }
}

func nextToken<Token :Equatable>(t: Token) -> Comb<Token, Token>.Parser {
    return predict { $0 == t }
}

func notToken<Token :Equatable>(t :Token) -> Comb<Token, Token>.Parser {
    return satisfy { $0 != t }
}

func oneOrMore<Token, Result>(parser: Comb<Token, Result>.Parser) -> Comb<Token, [Result]>.Parser {
    return oneOrMore(parser, buffer: [])
}

func zeroOrMore<Token, Result>(parser: Comb<Token, Result>.Parser) -> Comb<Token, [Result]>.Parser {
    return oneOrMore(parser) <|> pure([])
}

func zeroOrOne<Token, Result>(parser: Comb<Token, Result>.Parser) -> Comb<Token, [Result]>.Parser {
    return bind(parser) { r in return pure([r]) } <|> pure([])
}

private func oneOrMore<Token, Result>(parser: Comb<Token, Result>.Parser, buffer: [Result]) -> Comb<Token, [Result]>.Parser {
    return bind(parser) { r in
        let combine = buffer + [r]
        return oneOrMore(parser, buffer: combine) <|> pure(combine)
    }
}

infix operator <|> { associativity left precedence 130 }
func <|> <Token, Result>(lhs: Comb<Token, Result>.Parser, rhs: Comb<Token, Result>.Parser) -> Comb<Token, Result>.Parser {
    return { input in lhs(input) + rhs(input) }
}

infix operator <&> { associativity left precedence 130 }
func <&> <Token, Result>(lhs: Comb<Token, Result>.Parser, rhs: Comb<Token, Result>.Parser) -> Comb<Token, Result>.Parser {
    return { input in
        let lres = lhs(input)
        let rres = rhs(input)
        if (lres.count != 0) && (rres.count != 0) {
            return lres + rres
        }
        return []
    }
}

func ignoreWhitespace<T>(parser :Comb<Character, T>.Parser) -> Comb<Character, T>.Parser {
    return bind(zeroOrMore(NSCharacterSet.whitespaceAndNewlineCharacterSet().parser)) { result in
        return parser
    }
}

extension NSCharacterSet {
    var parser: Comb<Character, Character>.Parser {
        return satisfy { token in
            let unichar = (String(token) as NSString).characterAtIndex(0)
            return self.characterIsMember(unichar)
        }
    }
    
    var parserNot: Comb<Character, Character>.Parser {
        return satisfy { token in
            let unichar = (String(token) as NSString).characterAtIndex(0)
            return !self.characterIsMember(unichar)
        }
    }
    
    var parserPredict: Comb<Character, Character>.Parser {
        return predict { token in
            let unichar = (String(token) as NSString).characterAtIndex(0)
            return self.characterIsMember(unichar)
        }
    }
}

// basic regex

let alphabet : Comb<Character, Character>.Parser = bind(NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").parser) { r in
    return pure(r)
}

let escapedDQuote : Comb<Character, Character>.Parser = bind(token(Character("\\"))) { _ in
    bind(token(Character("\""))) { r in
        return pure(r)
    }
}

let escapedEscape : Comb<Character, Character>.Parser = bind(token(Character("\\"))) { _ in
    bind(token(Character("\\"))) { r in
        return pure(r)
    }
}

let notEscapeOrDQuote : Comb<Character, Character>.Parser = satisfy({($0 != Character("\"")) && ($0 != Character("\\"))})

let number : Comb<Character, Character>.Parser = bind(NSCharacterSet(charactersInString: "0123456789").parser) { r in
    return pure(r)
}

let specialInitialLetter : Comb<Character, Character>.Parser = bind(NSCharacterSet(charactersInString: "!$%&*/:<=>?^_~").parser) { r in
    return pure(r)
}

let specialFollowingLetter : Comb<Character, Character>.Parser = bind(NSCharacterSet(charactersInString: "+-.@").parser) { r in
    return pure(r)
}

let numberSign : Comb<Character, Character>.Parser = bind(NSCharacterSet(charactersInString: "+-").parser) { r in
    return pure(r)
}

let floatDot : Comb<Character, Character>.Parser = bind(token(".")) { r in
    return pure(r)
}

let divider : Comb<Character, Character>.Parser = NSCharacterSet.whitespaceAndNewlineCharacterSet().parserPredict <|> nextToken("(") <|> nextToken(")") <|> nextToken("\"") <|>  nextToken(";")

// Tokens

let tokenLParentheses : SingleTokenizer = bind(token("(")) { _ in
    return pure(LispToken.LParentheses)
}

let tokenRParentheses : SingleTokenizer = bind(token(")")) { _ in
    return pure(LispToken.RParentheses)
}

let trueBoolean : SingleTokenizer = bind(token("#")) { x in
    bind(token("t")) { _ in
        bind(divider) { _ in
            return pure(LispToken.Boolean(true))
        }
    }
}

let falseBoolean : SingleTokenizer = bind(token("#")) { x in
    bind(token("f")) { _ in
        bind(divider) { _ in
            return pure(LispToken.Boolean(false))
        }
    }
}

let tokenBool : SingleTokenizer = trueBoolean <|> falseBoolean

let tokenInt : SingleTokenizer = bind(zeroOrOne(numberSign)) { (x : [Character]) in
    bind(oneOrMore(number)) { (r : [Character]) in
        bind(divider) { (_: Character) in
            return pure(LispToken.LispInt(Int(NSString(string: String(x + r)).intValue)))
        }
    }
}

let tokenDouble : SingleTokenizer = bind(numberSign <|> number) { (x:Character) in
    bind(zeroOrMore(number)) { (y:[Character]) in
        bind(token(".")) { (z:Character) in
            bind(oneOrMore(number)) { (a:[Character]) in
                bind(divider) { _ in
                    let num = [x] + y + [z] + a
                    return pure(LispToken.LispDouble(Double(NSString(string: String(num)).doubleValue)))
                }
            }
        }
    }
}

let tokenString : SingleTokenizer = bind(token(Character("\""))) { _ in
    bind(zeroOrMore(notEscapeOrDQuote <|> escapedDQuote <|> escapedEscape )) { (r:[Character]) in
        bind(token(Character("\""))) { _ in
            return pure(LispToken.LispStr(String(r)))
        }
    }
}

let tokenChar : SingleTokenizer = bind(token("#")) { _ in
    bind(token(Character("\\"))) { _ in
        bind(NSCharacterSet.whitespaceAndNewlineCharacterSet().parserNot) { r in
            bind(divider) { _ in
                return pure(LispToken.LispChr(r))
            }
        }
    }
}

let tokenNull : SingleTokenizer = bind(token("n")) { _ in
    bind(token("u")) { _ in
        bind(token("l")) { _ in
            bind(token("l")) { _ in
                bind(divider) { _ in
                    return pure(LispToken.LispNull)
                }
            }
        }
    }
}

let identifier : SingleTokenizer = bind(alphabet <|> specialInitialLetter) { (a:Character) in
    bind(zeroOrMore(alphabet <|> number <|> specialInitialLetter <|> specialFollowingLetter)) { (b:[Character]) in
        bind(divider) { (_:Character) in
            return pure(LispToken.Symbol(String([a] + b)))
        }
    }
}

let uniqueIdentifier : SingleTokenizer = bind(NSCharacterSet(charactersInString: "+-").parser) { r in
    bind(divider) { _ in
        return pure(LispToken.Symbol(String(r)))
    }
}

let tokenSymbol : SingleTokenizer = identifier <|> uniqueIdentifier

let tokenVector : SingleTokenizer = bind(token("#")) { _ in
    bind(nextToken("(")) { _ in
        return pure(LispToken.VectorParentheses)
    }
}

let tokenQuote : SingleTokenizer = bind(token("'")) { _ in
    return pure(LispToken.Quote)
}

let tokenComma : SingleTokenizer = bind(token(",")) { _ in
    return pure(LispToken.Comma)
}

let tokenDot : SingleTokenizer = bind(token(".")) { _ in
    bind(divider) { _ in
        return pure(LispToken.Dot)
    }
}

// tokenizer

typealias LispTokenizer = Comb<Character, [LispToken]>.Parser

let lispTokenizer : LispTokenizer = oneOrMore(ignoreWhitespace(tokenSymbol <|> tokenBool <|> tokenInt <|> tokenDouble <|> tokenChar <|> tokenString <|> tokenLParentheses <|> tokenRParentheses <|> tokenVector <|> tokenQuote <|> tokenComma <|> tokenDot <|> tokenNull ))

// parse s-expression

func parenthesesParser<T>(factory: () -> Comb<LispToken, T>.Parser) -> Comb<LispToken, T>.Parser {
    return bind(satisfy { (t: LispToken) in t.isLParentheses }) { L in
        bind(factory()) { insideList in
            bind(satisfy { (t: LispToken) in t.isRParentheses }) { R in
                return pure(insideList)
            }
        }
    }
}

func parseLispExpr() -> Comb<LispToken, SExpr>.Parser {
    let atom : Comb<LispToken, SExpr>.Parser = bind(consumer()) { r in
        if r.isRParentheses || r.isLParentheses {
            return zero()
        } else {
            return pure(r.expr)
        }
    }
    
    return bind(parenthesesParser { zeroOrMore(parseLispExpr() <|> atom) }){ (var exprs: [SExpr]) in
        if exprs.count > 0 {
            //let head = exprs.removeAtIndex(0)
            let head = Pair()
            var pointer = head
            for var i = 0; exprs.count > (i + 1); i++ {
                pointer.car = exprs[i]
                pointer.cdr = Pair()
                pointer = pointer.cdr as! Pair
            }
            
            if let last = exprs.last {
                pointer.car = last
            }
            
            return pure(head)
        //} else if exprs.count == 1 {
        //    return pure(exprs[0])
        } else {
            return pure(MNull())
        }
    }
}


//
//  Parser+Operators.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

// EOF operator
postfix operator *!* { }

/**
 Match end-of-file.
 
 - returns: `ParserRule`.
 */
public postfix func *!* (rule: ParserRule) -> ParserRule {
    return { (parser: Parser, reader: Reader) -> Bool in
        return rule(parser: parser, reader: reader) && reader.eof()
    }
}

prefix operator ^ { }

/**
 Call a rule by a given `name`.
 
 - returns: `ParserRule`.
 
 - warning: Allows cycles.
 
 - TODO: Ensure cycles are prevented where possible.
 */
public prefix func ^ (name: String) -> ParserRule {
    return { (parser: Parser, reader: Reader) -> Bool in
        parser.enter("named rule: \(name)")
        
        // check to see if this would cause a recursive loop?
        if parser.currentNamedRule != name {
            let oldNamedRule = parser.currentNamedRule
            let rule = parser.namedRules[name]
            
            parser.currentNamedRule = name
            let result = rule!(parser: parser, reader: reader)
            parser.currentNamedRule = oldNamedRule
            
            parser.leave("named rule: \(name)",result)
            return result
        }
        
        parser.leave("named rule: - blocked", false)
        return false
    }
}

prefix operator %! { }

/**
 Match a regular expression with the given `pattern`.
 
 - returns: `ParserRule`.
 */
public prefix func %! (pattern: String) -> ParserRule {
    
    return { (parser: Parser, reader: Reader) -> Bool in
        parser.enter("regex '\(pattern)'")
        
        let position = reader.position
        
        var found = true
        let remainder = reader.remainder()
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let target = remainder as NSString
            let match = regex.firstMatchInString(remainder, options: [], range: NSMakeRange(0, target.length))
            if let match = match {
                let res = target.substringWithRange(match.range)
                // reset to end of match
                reader.seek(position + res.characters.count)
                
                parser.leave("regex", true)
                return true
            }
        } catch _ as NSError {
            found = false
        }
        
        if !found {
            reader.seek(position)
            parser.leave("regex", false)
        }
        return false
    }
}

// match a literal string
prefix operator % { }

/**
 Match a string literal.
 
 - returns: `Parser Rule`.
 */
public prefix func % (lit: String) -> ParserRule {
    return literal(lit)
}

public func literal(string: String) -> ParserRule {
    
    return { (parser: Parser, reader: Reader) -> Bool in
        
        parser.enter("literal '\(string)'")
        let pos = reader.position
        for character in string.characters {
            let flag = character == reader.read()
            if !flag {
                reader.seek(pos)
                
                parser.leave("literal", false)
                return false
            }
        }
        
        parser.leave("literal", true)
        return true
    }
}

/**
 Match a range of characters.
 
 For example, `"0"-"9"`
 
 - returns: `ParserRule`.
 */
public func - (left: Character, right: Character) -> ParserRule {
    return { (parser: Parser, reader: Reader) -> Bool in
        parser.enter("range [\(left)-\(right)]")
        
        let position = reader.position
        
        let lower = String(left)
        let upper = String(right)
        let character = String(reader.read())
        let found = (lower <= character) && (character <= upper)
        parser.leave("range \t\t\(character)", found)
        
        if !found {
            reader.seek(position)
        }
        
        return found
    }
}

/**
 Invert a given match.
 
 - returns: `ParserRule`.
 */
public prefix func ! (rule: ParserRule) -> ParserRule {
    return { (parser: Parser, reader: Reader) -> Bool in
        return !rule(parser: parser, reader: reader)
    }
}

public prefix func ! (lit: String) -> ParserRule {
    return !literal(lit)
}

postfix operator + { }

/**
 Match one or more.
 
 - returns: `ParserRule`.
 */
public postfix func + (rule: ParserRule) -> ParserRule {
    return { (parser: Parser, reader: Reader) -> Bool in
        let position = reader.position
        var found = false
        var flag: Bool
        
        parser.enter("one or more")
        
        repeat {
            flag = rule(parser: parser, reader: reader)
            found = found || flag
        } while flag
        
        if !found {
            reader.seek(position)
        }
        
        parser.leave("one or more", found)
        return found
    }
}

public postfix func + (lit: String) -> ParserRule {
    return literal(lit)+
}


postfix operator * { }

/**
 Match zero or more.
 
 - returns: `ParserRule`.
 */
public postfix func * (rule: ParserRule) -> ParserRule {
    return { (parser: Parser, reader: Reader) -> Bool in
        var flag: Bool
        var matched = false
        parser.enter("zero or more")
        
        repeat {
            let position = reader.position
            flag = rule(parser: parser, reader: reader)
            if(!flag) {
                reader.seek(position)
            } else {
                matched = true
            }
        } while flag
        
        parser.leave("zero or more", matched)
        return true
    }
}

public postfix func * (lit: String) -> ParserRule {
    return literal(lit)*
}

// optional
postfix operator /~ { }

/**
 Optionally match.
 
 - returns: `ParserRule`.
 */
public postfix func /~ (rule: ParserRule) -> ParserRule {
    
    return {(parser: Parser, reader: Reader) -> Bool in
        parser.enter("optionally")
        
        let position = reader.position
        if !rule(parser: parser, reader: reader) {
            reader.seek(position)
        }
        
        parser.leave("optionally", true)
        return true
    }
}

public postfix func /~ (lit: String) -> ParserRule {
    return literal(lit)/~
}

/**
 Match either.
 
 - returns: `ParserRule`.
 */
public func | (left: String, right: String) -> ParserRule {
    return literal(left) | literal(right)
}

/**
 Match either.
 
 - returns: `ParserRule`.
 */
public func | (left: String, right: ParserRule) -> ParserRule {
    return literal(left) | right
}

/**
 Match either.
 
 - returns: `ParserRule`.
 */
public func | (left: ParserRule, right: String) -> ParserRule {
    return left | literal(right)
}

/**
 Match either.
 
 - returns: `ParserRule`.
 */
public func | (left: ParserRule, right: ParserRule) -> ParserRule {
    return {(parser: Parser, reader: Reader) -> Bool in
        parser.enter("|")
        let position = reader.position
        var result = left(parser: parser, reader: reader)
        if !result {
            reader.seek(position)
            result = right(parser: parser, reader: reader)
        }
        
        if !result {
            reader.seek(position)
        }
        
        parser.leave("|", result)
        return result
    }
}

// match all
infix operator ~ { associativity left precedence 10 }

/**
 Match all.
 
 - returns: `ParserRule`
 */
public func ~ (left: String, right: String) -> ParserRule {
    return literal(left) ~ literal(right)
}

/**
 Match all.
 
 - returns: `ParserRule`
 */
public func ~ (left: String, right: ParserRule) -> ParserRule {
    return literal(left) ~ right
}

/**
 Match all.
 
 - returns: `ParserRule`
 */
public func ~ (left: ParserRule, right: String) -> ParserRule {
    return left ~ literal(right)
}

/**
 Match all.
 
 - returns: `ParserRule`
 */
public func ~ (left : ParserRule, right: ParserRule) -> ParserRule {
    return { (parser: Parser, reader: Reader) -> Bool in
        parser.enter("~")
        let res = left(parser: parser, reader: reader) && right(parser: parser, reader: reader)
        parser.leave("~", res)
        return res
    }
}

// on match
infix operator => { associativity right precedence 100 }

/**
 On match.
 
 - returns: `ParserRule`.
 */
public func => (rule : ParserRule, action: ParserAction) -> ParserRule {
    
    return { (parser: Parser, reader: Reader) -> Bool in
        let start = reader.position
        let captureCount = parser.captures.count
        
        parser.enter("=>")
        
        if rule(parser: parser, reader: reader) {
            let capture = Parser.ParserCapture(
                start: start,
                end: reader.position,
                action: action,
                reader: reader
            )
            
            parser.captures.append(capture)
            parser.leave("=>", true)
            return true
        }
        
        while(parser.captures.count > captureCount) {
            parser.captures.removeLast()
        }
        parser.leave("=>", false)
        return false
    }
}

infix operator ~~ { associativity left precedence 10 }

/**
 Match two following elements, optionally with whitespace.
 
 - note: You may configure the whitespace with the `Parser.whitespace` static property.
 
 - returns: `ParserRule`.
 */
public func ~~ (left: String, right: String) -> ParserRule {
    return literal(left) ~~ literal(right)
}

/**
 Match two following elements, optionally with whitespace.
 
 - note: You may configure the whitespace with the `Parser.whitespace` static property.
 
 - returns: `ParserRule`.
 */
public func ~~ (left: String, right: ParserRule) -> ParserRule {
    return literal(left) ~~ right
}

/**
 Match two following elements, optionally with whitespace.
 
 - note: You may configure the whitespace with the `Parser.whitespace` static property.
 
 - returns: `ParserRule`.
 */
public func ~~ (left: ParserRule, right: String) -> ParserRule {
    return left ~~ literal(right)
}

/**
 Match two following elements, optionally with whitespace.
 
 - note: You may configure the whitespace with the `Parser.whitespace` static property.
 
 - returns: `ParserRule`.
 */
public func ~~ (left : ParserRule, right: ParserRule) -> ParserRule {
    return {(parser: Parser, reader: Reader) -> Bool in
        return left(parser: parser, reader: reader) && parser.whitespace(parser: parser, reader: reader) && right(parser: parser, reader: reader)
    }
}

/** Parser rule that matches the given parser rule at least once, but possibly more */
public postfix func ++ (left: ParserRule) -> ParserRule {
    return left ~~ left*
}

public typealias ParserRuleDefinition = () -> ParserRule

infix operator <- { }

public func <- (left: Parser, right: ParserRuleDefinition) -> () {
    left.ruleDefinitions.append(right)
}
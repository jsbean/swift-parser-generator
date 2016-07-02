//
//  Parser+Follows.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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

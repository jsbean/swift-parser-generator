//
//  Parser+All.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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

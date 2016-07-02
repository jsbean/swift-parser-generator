//
//  Parser+Either.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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
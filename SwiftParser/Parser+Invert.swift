//
//  Parser+Invert.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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

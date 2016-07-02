//
//  Parser+Optional.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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

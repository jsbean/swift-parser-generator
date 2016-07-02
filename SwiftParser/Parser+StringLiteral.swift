//
//  Parser+StringLiteral.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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

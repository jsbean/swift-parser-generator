//
//  Parser+ZeroOrMore.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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

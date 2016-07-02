//
//  Parser+OneOrMore.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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

/** Parser rule that matches the given parser rule at least once, but possibly more */
public postfix func ++ (left: ParserRule) -> ParserRule {
    return left ~~ left*
}

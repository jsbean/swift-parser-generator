//
//  Parser+NamedRule.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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

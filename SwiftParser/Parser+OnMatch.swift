//
//  Parser+OnMatch.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

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


//
//  Parser+RegEx.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

prefix operator %! { }

/**
 Match a regular expression with the given `pattern`.
 
 - returns: `ParserRule`.
 */
public prefix func %! (pattern: String) -> ParserRule {
    
    return { (parser: Parser, reader: Reader) -> Bool in
        parser.enter("regex '\(pattern)'")
        
        let position = reader.position
        
        var found = true
        let remainder = reader.remainder()
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let target = remainder as NSString
            let match = regex.firstMatchInString(remainder, options: [], range: NSMakeRange(0, target.length))
            if let match = match {
                let res = target.substringWithRange(match.range)
                // reset to end of match
                reader.seek(position + res.characters.count)
                
                parser.leave("regex", true)
                return true
            }
        } catch _ as NSError {
            found = false
        }
        
        if !found {
            reader.seek(position)
            parser.leave("regex", false)
        }
        return false
    }
}

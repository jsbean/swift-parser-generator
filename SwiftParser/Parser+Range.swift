//
//  Parser+Range.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

/**
 Match a range of characters.
 
 For example, `"0"-"9"`
 
 - returns: `ParserRule`.
 */
public func - (left: Character, right: Character) -> ParserRule {
    return { (parser: Parser, reader: Reader) -> Bool in
        parser.enter("range [\(left)-\(right)]")
        
        let position = reader.position
        
        let lower = String(left)
        let upper = String(right)
        let character = String(reader.read())
        let found = (lower <= character) && (character <= upper)
        parser.leave("range \t\t\(character)", found)
        
        if !found {
            reader.seek(position)
        }
        
        return found
    }
}

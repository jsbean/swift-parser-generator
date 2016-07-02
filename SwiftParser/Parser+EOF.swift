//
//  Parser+EOF.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

// EOF operator
postfix operator *!* { }

/**
 Match end-of-file.
 
 - returns: `ParserRule`.
 */
public postfix func *!* (rule: ParserRule) -> ParserRule {
    return { (parser: Parser, reader: Reader) -> Bool in
        return rule(parser: parser, reader: reader) && reader.eof()
    }
}

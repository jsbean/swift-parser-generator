//
//  Reader.swift
//  SwiftParser
//
//  Created by Daniel Parnell on 17/06/2014.
//  Copyright (c) 2014 Daniel Parnell. All rights reserved.
//

import Foundation

/**
 Protocol defining interface for string scanning objects.
 */
public protocol Reader {
    
    /// Current position of `Reader`.
    var position: Int { get }
    
    /**
     Move to given `position`.
     */
    func seek(position: Int)
    
    /**
     Read the next character.
     */
    func read() -> Character
    
    /**
     - returns: Substring within the given interval.
     */
    func substring(startingAt startIndex: Int, endingAt endIndex: Int) -> String
    
    /**
     - returns: `true` if `Reader` has reached the end of the file. Otherwise, `false`.
     */
    func eof() -> Bool
    
    /**
     - returns: Remaining, unconsumed component of string.
     */
    func remainder() -> String
}

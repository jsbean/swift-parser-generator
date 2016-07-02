//
//  StringReader.swift
//  SwiftParser
//
//  Created by Daniel Parnell on 17/06/2014.
//  Copyright (c) 2014 Daniel Parnell. All rights reserved.
//

import Foundation

/// `Reader` implementation that reads `String` values.
public class StringReader: Reader {
    
    /// Current position of `StringReader`.
    public var position: Int {
        return string.startIndex.distanceTo(index)
    }
    
    private var string: String
    private var index: String.Index
    
    /**
     Create a `StringReader` with a given `string`.
     */
    init(string: String) {
        self.string = string
        self.index = string.startIndex
    }
    
    /**
     Move to given `position`.
     */
    public func seek(position: Int) {
        index = string.startIndex.advancedBy(position)
    }
    
    /**
     Read the next character.
     */
    public func read() -> Character {
        guard index != string.endIndex else { return "\u{2004}" }
        let result = string[index]
        index = index.successor()
        return result
    }
    
    /**
     - returns: Substring within the given interval.
     */
    public func substring(startingAt startIndex: Int, endingAt endIndex: Int) -> String {
        return string.substringWithRange(
            string.startIndex.advancedBy(startIndex)..<string.startIndex.advancedBy(endIndex)
        )
    }
    
    /**
     - returns: Remaining, unconsumed component of string.
     */
    public func remainder() -> String {
      return string.substringFromIndex(index)
    }

    /**
     - returns: `true` if `Reader` has reached the end of the file. Otherwise, `false`.
     */
    public func eof() -> Bool {
        return index == string.endIndex
    }
}

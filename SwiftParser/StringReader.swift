//
//  StringReader.swift
//  SwiftParser
//
//  Created by Daniel Parnell on 17/06/2014.
//  Copyright (c) 2014 Daniel Parnell. All rights reserved.
//

import Foundation

public class StringReader: Reader {
    
    var string: String
    var index: String.Index
    
    public var position: Int {
        get {
            return string.startIndex.distanceTo(index)
        }
    }
    
    init(string: String) {
        self.string = string
        self.index = string.startIndex
    }
    
    public func seek(position: Int) {
        index = string.startIndex.advancedBy(position)
    }
    
    public func read() -> Character {
        guard index != string.endIndex else { return "\u{2004}" }
        let result = string[index]
        index = index.successor()
        return result
    }
    
    public func eof() -> Bool {
        return index == string.endIndex
    }
    
    public func remainder() -> String {
      return string.substringFromIndex(index)
    }
  
    public func substring(startingAt startIndex: Int, endingAt endIndex: Int) -> String {
        return string.substringWithRange(
            string.startIndex.advancedBy(startIndex)..<string.startIndex.advancedBy(endIndex)
        )
    }
}
//
//  Reader.swift
//  SwiftParser
//
//  Created by Daniel Parnell on 17/06/2014.
//  Copyright (c) 2014 Daniel Parnell. All rights reserved.
//

import Foundation

public protocol Reader {
    var position: Int { get }
    
    func seek(position: Int)
    func read() -> Character
    func substring(startingAt startIndex: Int, endingAt endIndex: Int) -> String
    func eof() -> Bool
    func remainder() -> String
}

//
//  ParserRuleDefinition.swift
//  SwiftParser
//
//  Created by James Bean on 7/2/16.
//  Copyright © 2016 Daniel Parnell. All rights reserved.
//

import Foundation

public typealias ParserRuleDefinition = () -> ParserRule

infix operator <- { }

public func <- (left: Parser, right: ParserRuleDefinition) -> () {
    left.ruleDefinitions.append(right)
}

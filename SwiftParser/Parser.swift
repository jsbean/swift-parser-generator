//
//  Parser.swift
//  SwiftParser
//
//  Created by Daniel Parnell on 17/06/2014.
//  Copyright (c) 2014 Daniel Parnell. All rights reserved.
//

import Foundation

/**
 Function that returns whether of not the given `reader` can be parsed by the given `parser`.
*/
public typealias ParserRule = (parser: Parser, reader: Reader) -> Bool

public typealias ParserAction = () -> ()

/// Parser
public class Parser {
    
    public struct ParserCapture: CustomStringConvertible {
        
        public var start: Int
        public var end: Int
        public var action: ParserAction
        
        let reader: Reader

		var text: String {
            return reader.substring(startingAt: start, endingAt: end)
        }

        public var description: String {
            return "[\(start),\(end):\(text)]"
        }
    }
    
    public var ruleDefinition: ParserRuleDefinition?
    public var ruleDefinitions: [ParserRuleDefinition] = []
    public var startRule: ParserRule?
    public var debugRules = false

    public var captures: [ParserCapture] = []
    public var currentCapture: ParserCapture?
    public var lastCapture: ParserCapture?
    public var currentReader: Reader?

    internal var namedRules: [String: ParserRule] = [:]
    internal var currentNamedRule = ""

	/** This rule determines what is seen as 'whitespace' by the '~~'  operator, which allows whitespace between two
	 following items.*/
	public var whitespace: ParserRule = (" " | "\t" | "\r\n" | "\r" | "\n")*

    /// Text held by `currentCapture`, if present. Otherwise an empty string.
    public var text: String {
        return currentCapture?.text ?? ""
    }
    
    /**
     Create a `Parser`.
     */
    public init() {
        rules()
    }
    
    /**
     Create a `Parser` with a `ParserRuleDefinition`.
     */
    public init(ruleDefinition: ParserRuleDefinition) {
        self.ruleDefinition = ruleDefinition
    }
    
    public func addNamedRule(name: String, rule: ParserRule) {
        namedRules[name] = rule
    }
    
    // For subclasses to override
    public func rules() {
        
    }
    
    /**
     Parse a given `string`.
     
     - returns: `true` if `string` ws successfully parsed. Otherwise, `false`.
     
     - TODO: Find way of unwrapping `startRule` elegantly.
     */
    public func parse(string: String) -> Bool {
        
        if startRule == nil {
            startRule = ruleDefinition!()
        }
        
        captures.removeAll(keepCapacity: true)
        currentCapture = nil
        lastCapture = nil
        
        let reader = StringReader(string: string)
        
        if startRule!(parser: self, reader: reader) {
            currentReader = reader
            
            for capture in captures {
                lastCapture = currentCapture
                currentCapture = capture
                capture.action()
            }

            currentReader = nil
            currentCapture = nil
            lastCapture = nil
            return true
        }
        
        return false
    }
    
    // TODO: find better way of doing this?
    // -- perhaps: inout depth: Int
    
    internal var depth = 0
    
    internal func leave(name: String) {
        if debugRules {
            self.out("-- \(name)")
        }
        depth -= 1
    }
    
    internal func leave(name: String, _ res: Bool) {
        if debugRules {
            self.out("-- \(name):\t\(res)")
        }
        depth -= 1
    }
    
    internal func enter(name: String) {
        depth += 1
        if debugRules {
            self.out("++ \(name)")
        }
    }
    
    internal func out(name: String) {
        let spaces = (0 ..< (depth - 1)).map { _ in "  " }
        print("\(spaces)\(name)")
    }
}

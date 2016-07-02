//
//  SwiftParserTests.swift
//  SwiftParserTests
//
//  Created by Daniel Parnell on 17/06/2014.
//  Copyright (c) 2014 Daniel Parnell. All rights reserved.
//

import XCTest
import SwiftParser

class SwiftParserTests: XCTestCase {
    
    class Calculator {
        
        var stack: [Double] = []
        var isNegative = false
        
        var result: Double {
            return stack[stack.count-1]
        }
        
        func performBinaryOperation(op: (left: Double, right: Double) -> Double) {
            let right = stack.removeLast()
            let left = stack.removeLast()
            
            stack.append(op(left: left, right: right))
        }
        
        func add() {
            performBinaryOperation { (left: Double, right: Double) -> Double in
                return left + right
            }
        }
        
        func divide() {
            performBinaryOperation { (left: Double, right: Double) -> Double in
                return left / right
            }
        }
        
        func exponent() {
            performBinaryOperation{ (left: Double, right: Double) -> Double in
                return pow(left, right)
            }
        }
        
        func multiply() {
            performBinaryOperation{ (left: Double, right: Double) -> Double in
                return left * right
            }
        }
        
        func subtract() {
            performBinaryOperation { (left: Double, right: Double) -> Double in
                return left - right
            }
        }
        
        func negative() {
            isNegative = !isNegative
        }
        
        func pushNumber(text: String) {
            var value: Double = 0
            var decimal = -1
            var counter = 0
            for character in text.utf8 {
                if character == 46 {
                    decimal = counter
                } else {
                    let digit = Int(character) - 48
                    value = value * 10.0 + Double(digit)
                    counter = counter + 1
                }
            }
            
            if decimal >= 0 {
                value = value / pow(10.0, Double(counter - decimal))
            }
            
            if isNegative {
                value = -value
            }
            
            stack.append(value)
        }
        
    }
    
    class Arithmetic: Parser {
        var calculator = Calculator()
        
        func push() {
            calculator.pushNumber(text)
        }
        
        func add() {
            calculator.add()
        }
        
        func sub() {
            calculator.subtract()
        }
        
        func mul() {
            calculator.multiply()
        }
        
        func div() {
            calculator.divide()
        }
        
        override func rules() {
            startRule = (^"primary")*!*
            
            let number = ("0"-"9")+ => push
            addNamedRule("primary",   rule: ^"secondary" ~ (("+" ~ ^"secondary" => add) | ("-" ~ ^"secondary" => sub))*)
            addNamedRule("secondary", rule: ^"tertiary" ~ (("*" ~ ^"tertiary" => mul) | ("/" ~ ^"tertiary" => div))*)
            addNamedRule("tertiary",  rule: ("(" ~ ^"primary" ~ ")") | number)
        }
    }
    
    // A recursive parser like the following will always fail as it results in an infinite recursive loop.  Code has been added to try to catch this, but you have been warned!
    class RecursiveArithmetic: Arithmetic {
        override func rules() {
            startRule = (^"term")*!*
            
            let num = ("0"-"9")+ => push
            addNamedRule("term", rule: ((^"term" ~ "+" ~ ^"fact") => add) | ((^"term" ~ "-" ~ ^"fact") => sub) | ^"fact")
            addNamedRule("fact", rule: ((^"fact" ~ "*" ~ ^"term") => mul) | ((^"fact" ~ "/" ~ ^"term") => div) | ("(" ~ ^"term" ~ ")") | num)
        }
    }

   
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimple() {
        let a = Arithmetic()
        XCTAssert(a.parse("1+2"))
        XCTAssertEqual(a.calculator.result, 3)
    }

    func testComplex() {
        let a = Arithmetic()
        XCTAssert(a.parse("6*7-3+20/2-12+(30-5)/5"))
        XCTAssertEqual(a.calculator.result, 42)
    }

    func testRecursiveSimple() {
        let a = RecursiveArithmetic()
        XCTAssertFalse(a.parse("1+2"))
    }
    
    func testRecursiveComplex() {
        let a = RecursiveArithmetic()
        
        XCTAssertFalse(a.parse("6*7-3+20/2-12+(30-5)/5"))
    }
    
    func testShouldNotParse() {
        let a = Arithmetic()
        XCTAssertFalse(a.parse("1+"))
        XCTAssertFalse(a.parse("xxx"))
    }
}

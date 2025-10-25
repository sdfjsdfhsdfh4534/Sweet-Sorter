//
//  RuleEngine.swift
//  N1021erwtywrewth
//
//  Created by Agent on 24.10.2025.
//

import Foundation

// MARK: - Rule Engine
class RuleEngine {
    
    // MARK: - Token Types
    private enum Token: Equatable {
        case attribute(String)
        case value(String)
        case number(Int)
        case comparison(ComparisonOp)
        case logicalOp(LogicalOp)
        case leftParen
        case rightParen
        case elseToken
        
        enum ComparisonOp: String {
            case equal = "="
            case notEqual = "!="
            case greaterEqual = "≥"
            case lessEqual = "≤"
            case greater = ">"
            case less = "<"
        }
        
        enum LogicalOp: String {
            case and = "AND"
            case or = "OR"
            case not = "NOT"
        }
    }
    
    // MARK: - Expression Tree
    private indirect enum Expression {
        case comparison(String, Token.ComparisonOp, String)
        case logical(LogicalOp, [Expression])
        case elseExpr
        
        enum LogicalOp {
            case and, or, not
        }
    }
    
    // MARK: - Public Methods
    static func evaluate(candy: Candy, rule: String) -> Bool {
        let trimmed = rule.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.uppercased() == "ELSE" {
            return true
        }
        
        do {
            let tokens = try tokenize(rule: trimmed)
            let expression = try parse(tokens: tokens)
            return evaluate(expression: expression, candy: candy)
        } catch {
            print("Rule evaluation error: \(error)")
            return false
        }
    }
    
    static func findMatchingJar(candy: Candy, jars: [Jar]) -> Jar? {
        for jar in jars {
            if evaluate(candy: candy, rule: jar.rule) {
                return jar
            }
        }
        return nil
    }
    
    // MARK: - Tokenization
    private static func tokenize(rule: String) throws -> [Token] {
        var tokens: [Token] = []
        var current = ""
        var i = rule.startIndex
        
        while i < rule.endIndex {
            let char = rule[i]
            
            if char.isWhitespace {
                if !current.isEmpty {
                    try appendToken(&tokens, current: &current)
                }
                i = rule.index(after: i)
                continue
            }
            
            if char == "(" {
                if !current.isEmpty {
                    try appendToken(&tokens, current: &current)
                }
                tokens.append(.leftParen)
                i = rule.index(after: i)
                continue
            }
            
            if char == ")" {
                if !current.isEmpty {
                    try appendToken(&tokens, current: &current)
                }
                tokens.append(.rightParen)
                i = rule.index(after: i)
                continue
            }
            
            // Check for comparison operators
            if char == "=" || char == "!" || char == ">" || char == "<" || char == "≥" || char == "≤" {
                if !current.isEmpty {
                    try appendToken(&tokens, current: &current)
                }
                
                var opString = String(char)
                let next = rule.index(after: i)
                if next < rule.endIndex && rule[next] == "=" {
                    opString += "="
                    i = next
                }
                
                if let op = Token.ComparisonOp(rawValue: opString) {
                    tokens.append(.comparison(op))
                }
                i = rule.index(after: i)
                continue
            }
            
            current.append(char)
            i = rule.index(after: i)
        }
        
        if !current.isEmpty {
            try appendToken(&tokens, current: &current)
        }
        
        return tokens
    }
    
    private static func appendToken(_ tokens: inout [Token], current: inout String) throws {
        let upper = current.uppercased()
        
        if upper == "ELSE" {
            tokens.append(.elseToken)
        } else if upper == "AND" {
            tokens.append(.logicalOp(.and))
        } else if upper == "OR" {
            tokens.append(.logicalOp(.or))
        } else if upper == "NOT" {
            tokens.append(.logicalOp(.not))
        } else if upper == "TRUE" || upper == "FALSE" {
            tokens.append(.value(upper.lowercased()))
        } else if let num = Int(current) {
            tokens.append(.number(num))
        } else if ["color", "shape", "size", "pattern", "flavor", "wrapped", "layers"].contains(current.lowercased()) {
            tokens.append(.attribute(current.lowercased()))
        } else {
            tokens.append(.value(current.lowercased()))
        }
        
        current = ""
    }
    
    // MARK: - Parsing
    private static func parse(tokens: [Token]) throws -> Expression {
        var index = 0
        return try parseOr(tokens: tokens, index: &index)
    }
    
    private static func parseOr(tokens: [Token], index: inout Int) throws -> Expression {
        var left = try parseAnd(tokens: tokens, index: &index)
        
        while index < tokens.count, case .logicalOp(.or) = tokens[index] {
            index += 1
            let right = try parseAnd(tokens: tokens, index: &index)
            left = .logical(.or, [left, right])
        }
        
        return left
    }
    
    private static func parseAnd(tokens: [Token], index: inout Int) throws -> Expression {
        var left = try parseNot(tokens: tokens, index: &index)
        
        while index < tokens.count, case .logicalOp(.and) = tokens[index] {
            index += 1
            let right = try parseNot(tokens: tokens, index: &index)
            left = .logical(.and, [left, right])
        }
        
        return left
    }
    
    private static func parseNot(tokens: [Token], index: inout Int) throws -> Expression {
        if index < tokens.count, case .logicalOp(.not) = tokens[index] {
            index += 1
            let expr = try parseNot(tokens: tokens, index: &index)
            return .logical(.not, [expr])
        }
        
        return try parsePrimary(tokens: tokens, index: &index)
    }
    
    private static func parsePrimary(tokens: [Token], index: inout Int) throws -> Expression {
        guard index < tokens.count else {
            throw RuleError.unexpectedEndOfTokens
        }
        
        let token = tokens[index]
        
        if case .elseToken = token {
            index += 1
            return .elseExpr
        }
        
        if case .leftParen = token {
            index += 1
            let expr = try parseOr(tokens: tokens, index: &index)
            guard index < tokens.count, case .rightParen = tokens[index] else {
                throw RuleError.missingClosingParen
            }
            index += 1
            return expr
        }
        
        if case .attribute(let attr) = token {
            index += 1
            guard index < tokens.count, case .comparison(let op) = tokens[index] else {
                throw RuleError.expectedComparison
            }
            index += 1
            guard index < tokens.count else {
                throw RuleError.expectedValue
            }
            
            let valueToken = tokens[index]
            index += 1
            
            let value: String
            if case .value(let v) = valueToken {
                value = v
            } else if case .number(let n) = valueToken {
                value = String(n)
            } else {
                throw RuleError.expectedValue
            }
            
            return .comparison(attr, op, value)
        }
        
        throw RuleError.unexpectedToken
    }
    
    // MARK: - Evaluation
    private static func evaluate(expression: Expression, candy: Candy) -> Bool {
        switch expression {
        case .elseExpr:
            return true
            
        case .comparison(let attr, let op, let value):
            return evaluateComparison(candy: candy, attribute: attr, op: op, value: value)
            
        case .logical(let logicOp, let exprs):
            switch logicOp {
            case .and:
                return exprs.allSatisfy { evaluate(expression: $0, candy: candy) }
            case .or:
                return exprs.contains { evaluate(expression: $0, candy: candy) }
            case .not:
                return exprs.first.map { !evaluate(expression: $0, candy: candy) } ?? false
            }
        }
    }
    
    private static func evaluateComparison(candy: Candy, attribute: String, op: Token.ComparisonOp, value: String) -> Bool {
        switch attribute {
        case "color":
            return compareString(candy.color.rawValue, op, value)
        case "shape":
            return compareString(candy.shape.rawValue, op, value)
        case "size":
            return compareString(candy.size.rawValue, op, value)
        case "pattern":
            return compareString(candy.pattern.rawValue, op, value)
        case "flavor":
            return compareString(candy.flavor.rawValue, op, value)
        case "wrapped":
            let candyValue = candy.wrapped ? "true" : "false"
            return compareString(candyValue, op, value)
        case "layers":
            return compareNumber(candy.layers, op, Int(value) ?? 0)
        default:
            return false
        }
    }
    
    private static func compareString(_ left: String, _ op: Token.ComparisonOp, _ right: String) -> Bool {
        switch op {
        case .equal:
            return left.lowercased() == right.lowercased()
        case .notEqual:
            return left.lowercased() != right.lowercased()
        default:
            return false
        }
    }
    
    private static func compareNumber(_ left: Int, _ op: Token.ComparisonOp, _ right: Int) -> Bool {
        switch op {
        case .equal:
            return left == right
        case .notEqual:
            return left != right
        case .greater:
            return left > right
        case .less:
            return left < right
        case .greaterEqual:
            return left >= right
        case .lessEqual:
            return left <= right
        }
    }
    
    // MARK: - Errors
    enum RuleError: Error {
        case unexpectedEndOfTokens
        case missingClosingParen
        case expectedComparison
        case expectedValue
        case unexpectedToken
    }
}

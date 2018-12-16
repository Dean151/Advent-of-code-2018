//
//  Day16.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 16/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day16: Day {
    
    enum OpCode: CaseIterable {
        case addr, addi
        case mulr, muli
        case banr, bani
        case borr, bori
        case setr, seti
        case gtir, gtri, gtrr
        case eqir, eqri, eqrr
        
        func perform(operation: [Int], with register: [Int]) -> [Int] {
            var newRegister = register
            switch self {
            case .addr:
                newRegister[operation[3]] = register[operation[1]] + register[operation[2]]
            case .addi:
                newRegister[operation[3]] = register[operation[1]] + operation[2]
            case .mulr:
                newRegister[operation[3]] = register[operation[1]] * register[operation[2]]
            case .muli:
                newRegister[operation[3]] = register[operation[1]] * operation[2]
            case .banr:
                newRegister[operation[3]] = register[operation[1]] & register[operation[2]]
            case .bani:
                newRegister[operation[3]] = register[operation[1]] & operation[2]
            case .borr:
                newRegister[operation[3]] = register[operation[1]] | register[operation[2]]
            case .bori:
                newRegister[operation[3]] = register[operation[1]] | operation[2]
            case .setr:
                newRegister[operation[3]] = register[operation[1]]
            case .seti:
                newRegister[operation[3]] = operation[1]
            case .gtir:
                newRegister[operation[3]] = operation[1] > register[operation[2]] ? 1 : 0
            case .gtri:
                newRegister[operation[3]] = register[operation[1]] > operation[2] ? 1 : 0
            case .gtrr:
                newRegister[operation[3]] = register[operation[1]] > register[operation[2]] ? 1 : 0
            case .eqir:
                newRegister[operation[3]] = operation[1] == register[operation[2]] ? 1 : 0
            case .eqri:
                newRegister[operation[3]] = register[operation[1]] == operation[2] ? 1 : 0
            case .eqrr:
                newRegister[operation[3]] = register[operation[1]] == register[operation[2]] ? 1 : 0
            }
            return newRegister
        }
        
        static func identifyOperation(before: [Int], operation: [Int], after: [Int]) -> Set<OpCode> {
            var matchingCodes = Set<OpCode>()
            for code in OpCode.allCases {
                if code.perform(operation: operation, with: before) == after {
                    matchingCodes.insert(code)
                }
            }
            return matchingCodes
        }
    }
    
    static func run(input: String) {
        let lines = input.components(separatedBy: .newlines)
        
        var matchingOperations = [Int: Set<OpCode>]()
        
        let beforeRegex = try! NSRegularExpression(pattern: "^Before: \\[(\\d+), (\\d+), (\\d+), (\\d+)\\]$", options: .caseInsensitive)
        var before = [Int]()
        
        let opRegex = try! NSRegularExpression(pattern: "^(\\d+) (\\d+) (\\d+) (\\d+)$", options: .caseInsensitive)
        var op = [Int]()
        
        let afterRegex = try! NSRegularExpression(pattern: "^After:  \\[(\\d+), (\\d+), (\\d+), (\\d+)\\]$", options: .caseInsensitive)
        var after = [Int]()
        
        var moreThan3 = 0
        
        for line in lines {
            if let match = beforeRegex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count)).first {
                before = [1, 2, 3, 4].map({ Int(match.group(at: $0, in: line))! })
            }
            
            if let match = opRegex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count)).first {
                op = [1, 2, 3, 4].map({ Int(match.group(at: $0, in: line))! })
            }
            
            if let match = afterRegex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count)).first {
                after = [1, 2, 3, 4].map({ Int(match.group(at: $0, in: line))! })
                let matching = OpCode.identifyOperation(before: before, operation: op, after: after)
                moreThan3 += matching.count >= 3 ? 1 : 0
                if let otherMatch = matchingOperations[op[0]] {
                    matchingOperations.updateValue(matching.intersection(otherMatch), forKey: op[0])
                } else {
                    matchingOperations.updateValue(matching, forKey: op[0])
                }
            }
        }
        
        print("Number of matching with 3+ opcodes for Day 16-1 is \(moreThan3)")
    }
}

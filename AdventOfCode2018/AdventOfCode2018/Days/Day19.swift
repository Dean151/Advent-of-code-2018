//
//  Day19.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 19/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

extension Day16.OpCode {
    static func from(string: String) -> Day16.OpCode? {
        switch string {
        case "addr":
            return .addr
        case "addi":
            return .addi
        case "mulr":
            return .mulr
        case "muli":
            return .muli
        case "banr":
            return .banr
        case "bani":
            return .bani
        case "borr":
            return .borr
        case "bori":
            return bori
        case "setr":
            return .setr
        case "seti":
            return .seti
        case "gtir":
            return .gtir
        case "gtri":
            return .gtri
        case "gtrr":
            return .gtrr
        case "eqir":
            return .eqir
        case "eqri":
            return .eqri
        case "eqrr":
            return .eqrr
        default:
            return nil
        }
    }
}

class Day19: Day {
    
    typealias Operation = (code: Day16.OpCode, a: Int, b: Int, c: Int)
    
    static func parse(lines: [String]) -> (ip: Int, operations: [Operation]) {
        var ip = 0
        var operations = [Operation]()
        for line in lines {
            let words = line.components(separatedBy: .whitespaces)
            if words.count == 2, let initialIp = Int(words[1]) {
                ip = initialIp
                continue
            }
            if words.count != 4 {
                continue
            }
            guard let op = Day16.OpCode.from(string: words[0]), let a = Int(words[1]), let b = Int(words[2]), let c = Int(words[3]) else {
                continue
            }
            operations.append((code: op, a: a, b: b, c: c))
        }
        return (ip: ip, operations: operations)
    }
    
    static func register(program: (ip: Int, operations: [Operation]), from registry: [Int]) -> [Int] {
        let (ip, operations) = program
        
        var registry = registry
        var current = registry[ip]
        while current >= 0 && current < operations.count {
            registry[ip] = current
            let operation = operations[current]
            registry = operation.code.perform(operation: [0, operation.a, operation.b, operation.c], with: registry)
            current = registry[ip] + 1
        }
        return registry
    }
    
    static func run(input: String) {
        let (ip, operations) = parse(lines: input.components(separatedBy: .newlines).filter({ !$0.isEmpty }))
        
        let registry1 = register(program: (ip: ip, operations: operations), from: [0, 0, 0, 0, 0, 0])
        print("The value left in registry[0] for Day 19-1 is \(registry1[0])")
        
        let registry2 = register(program: (ip: ip, operations: operations), from: [1, 0, 0, 0, 0, 0])
        print("The value left in registry[0] for Day 19-1 is \(registry2[0])")
    }
}

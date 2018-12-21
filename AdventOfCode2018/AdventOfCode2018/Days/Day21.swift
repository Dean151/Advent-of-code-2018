//
//  Day21.swift
//  AdventOfCode2018
//
//  Created by Thomas DURAND on 21/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day21: Day {
    
    typealias Operation = (code: Day16.OpCode, a: Int, b: Int, c: Int)
    
    static func runProgram(program: (ip: Int, operations: [Operation]), breaking: Bool) -> Int {
        let (ip, operations) = program
        
        var last = 0
        var seen = Set<Int>()
        var registry = [0, 0, 0, 0, 0, 0]
        var current = registry[ip]
        while current >= 0 && current < operations.count {
            registry[ip] = current
            
            let operation = operations[current]
            registry = operation.code.perform(operation: [0, operation.a, operation.b, operation.c], with: registry)
            
            current = registry[ip] + 1
            
            if current == 28 {
                let value = registry[5]
                if breaking {
                    return value
                } else {
                    if seen.contains(value) {
                        return last
                    }
                    seen.insert(value)
                    last = value
                }
            }
        }
        return Int.max
    }
    
    static func run(input: String) {
        let program = Day19.parse(lines: input.components(separatedBy: .newlines).filter({ !$0.isEmpty }))
        // op 28 : eqrr 5 0 3 ;
        // The only one that uses registry 0 ; and compare it to 5 ; if so, store the result to 3
        // Then : addr 3 4 4 ; the value in 3 is added to the IP ; that make the program skip the last arg ; and break.
        // Let use this value of registry 5 as a solution.
        print("Solution for Day 21-1 is \(runProgram(program: program, breaking: true))")
        
        // Part 2 is more tricky ; we have to repeat until we get the last integer that was not already seen.
        print("Solution for Day 21-2 is \(runProgram(program: program, breaking: false))")
    }
}

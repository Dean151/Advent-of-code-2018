//
//  Day12.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 12/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day12: Day {
    
    static func rules(from strings: [String]) -> [String: Character] {
        var rules = [String: Character](minimumCapacity: strings.count)
        for string in strings {
            if string.isEmpty {
                continue
            }
            let components = string.components(separatedBy: " => ")
            let key = components.first!
            let caracter = components.last!.first!
            if key[key.index(key.startIndex, offsetBy: 2)] != caracter {
                // Only keep that mutate the plan
                rules.updateValue(caracter, forKey: components.first!)
            }
        }
        return rules
    }
    
    static func sum(for string: String, offset: Int) -> Int {
        var sum = 0
        for (i,c) in string.enumerated() {
            if c != "#" {
                continue
            }
            sum += i - offset
        }
        return sum
    }
    
    static func run(input: String) {
        let lines = input.components(separatedBy: .newlines)
        let initialState = lines.first!.components(separatedBy: .whitespaces).last!
        let rules = Day12.rules(from: [String](lines.dropFirst(2)))
        
        let nbGenerations = 50000000000
        var offset = 0
        var state = initialState
        for generation in 1...nbGenerations {
            var newState = ""
            offset += 2 - state.prefix(while: { $0 == "." }).count
            let workState = ".." + state.trimmingCharacters(in: CharacterSet.init(charactersIn: ".")) + ".."
            for (i, c) in workState.enumerated() {
                let missingStart = max(0, 2-i)
                let start = workState.index(workState.startIndex, offsetBy: i-2+missingStart)
                let missingEnd = max(0, 5 - workState.distance(from: start, to: workState.endIndex))
                let end = workState.index(start, offsetBy: 5 - missingStart - missingEnd)
                let key = String(repeating: ".", count: missingStart) + String(workState[start..<end]) + String(repeating: ".", count: missingEnd)
                newState.append(rules[key] ?? c)
            }
            
            if generation == 20 {
                let sum = self.sum(for: newState, offset: offset)
                print("Total sum of pots containing plants for Day 12-1 is \(sum)")
            }
                
            if state == newState {
                offset += (nbGenerations - generation) * (2 - state.prefix(while: { $0 == "." }).count)
                break
            }
            
            state = newState
        }
        
        let sum = self.sum(for: state, offset: offset)
        print("Total sum of pots containing plants for Day 12-2 is \(sum)")
    }
}

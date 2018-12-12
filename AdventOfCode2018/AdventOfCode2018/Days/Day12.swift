//
//  Day12.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 12/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day12: Day {
    
    static func rules(from strings: [String]) -> [String: Bool] {
        var rules = [String: Bool](minimumCapacity: strings.count)
        for string in strings {
            if string.isEmpty {
                continue
            }
            let components = string.components(separatedBy: " => ")
            let key = components.first!
            if key[key.index(key.startIndex, offsetBy: 2)] != components.last!.first! {
                // Only keep mutable rules
                rules.updateValue(components.last! == "#", forKey: components.first!)
            }
        }
        return rules
    }
    
    static func run(input: String) {
        var lines = input.components(separatedBy: .newlines)
        
        var state = [Int: Bool]()
        for (i,c) in lines.removeFirst().components(separatedBy: .whitespaces).last!.enumerated() {
            state[i] = c == "#"
        }
        
        lines.removeFirst() // Remove the empty line
        let rules = Day12.rules(from: lines)
        
        for gen in 1...50000000000 {
            var newState = [Int: Bool](minimumCapacity: state.count)
            for i in state.keys.min()!-4...state.keys.max()!+4 {
                let key = [Int](i-2...i+2).reduce("", { $0 + ((state[$1] ?? false) ? "#" : ".") })
                newState[i] = rules[key] ?? state[i]
            }
            state = newState
            
            if gen == 20 {
                let sum = state.reduce(0, { $0 + ($1.value ? $1.key : 0) })
                print("Total sum of pots containing plants for Day 12-1 is \(sum)")
            }
            if gen % 1000 == 0 {
                print(gen)
            }
        }
        
        let sum = state.reduce(0, { $0 + ($1.value ? $1.key : 0) })
        print("Total sum of pots containing plants for Day 12-2 is \(sum)")
    }
}

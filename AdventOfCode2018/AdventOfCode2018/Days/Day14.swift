//
//  Day14.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 14/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day14: Day {
    
    static func run(input: String) {
        let toFind = input.components(separatedBy: .newlines).first!
        let numberOfRecipies = Int(toFind)!
        
        var recipies = [3, 7]
        var currentA = 0
        var currentB = 1
        
        var part1done = false
        var part2done = false
        
        while !part1done || !part2done {
            let a = recipies[currentA]
            let b = recipies[currentB]
            
            let c = a + b
            let added: Int
            if c < 10 {
                recipies.append(c)
                added = 1
            } else {
                recipies.append(c / 10)
                recipies.append(c % 10)
                added = 2
            }
            
            if !part1done && recipies.count >= numberOfRecipies + 10 {
                let next = [Int](0...9).reduce(0, { return 10 * $0 + recipies[numberOfRecipies + $1] })
                print("Score of next ten recipies for Day 14-1 are \(next)")
                part1done = true
            }
            
            let suffix = recipies.suffix(toFind.count + (added - 1)).reduce("", { $0 + "\($1)" })
            if !part2done && suffix.contains(toFind) {
                let correct = suffix.hasPrefix(toFind) && added == 2 ? 1 : 0
                print("Input found after making \(recipies.count - correct - toFind.count) recipies for Day 14-2")
                part2done = true
            }
            
            currentA = (currentA + 1 + a) % recipies.count
            currentB = (currentB + 1 + b) % recipies.count
        }
    }
}

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
        let numberOfRecipies = Int(input.components(separatedBy: .newlines).first!)!
        
        var recipies = [3, 7]
        var currentA = 0
        var currentB = 1
        
        while recipies.count < numberOfRecipies + 10 {
            let a = recipies[currentA]
            let b = recipies[currentB]
            
            let c = a + b
            if c < 10 {
                recipies.append(c)
            } else {
                recipies.append(c / 10)
                recipies.append(c % 10)
            }
            
            currentA = (currentA + 1 + a) % recipies.count
            currentB = (currentB + 1 + b) % recipies.count
        }
        
        let next = [Int](0...9).reduce(0, { return 10 * $0 + recipies[numberOfRecipies + $1] })
        print("Score of next ten recipies for Day 14-1 are \(next)")
    }
}

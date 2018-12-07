//
//  Day7.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 07/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day7: Day {
    
    struct Step {
        
        let letter: Character
        var requirements: Set<Character>
        
        init(letter: Character) {
            self.letter = letter
            self.requirements = []
        }
        
        mutating func requires(new: Character) {
            self.requirements.insert(new)
        }
    }
    
    static func run(input: String) {
        var steps = [Character: Step](minimumCapacity: 26)
        
        // Parse the steps
        input.components(separatedBy: .newlines).forEach {
            let components = $0.components(separatedBy: .whitespaces)
            guard components.count == 10 else {
                return
            }
            let letter = components[7].first!
            let requires = components[1].first!
            
            // If needed, create the requirement
            if steps[requires] == nil {
                let step = Step(letter: requires)
                steps.updateValue(step, forKey: step.letter)
            }
            
            // Create the step requirement
            var step = steps[letter] ?? Step(letter: letter)
            step.requires(new: requires)
            steps.updateValue(step, forKey: step.letter)
        }
        
        // Will be easier if the steps are alphabetical right now!
        var nonExecuted = Set(steps.keys)
        var nonExecutedSteps = steps.values.sorted(by: { return $0.letter < $1.letter })
        
        // Now we execute our little game
        var orders = ""
        while (!nonExecuted.isEmpty) {
            for (i, step) in nonExecutedSteps.enumerated() {
                if !step.requirements.filter({ nonExecuted.contains($0) }).isEmpty {
                    continue
                }
                // The step is executed
                nonExecuted.remove(step.letter)
                nonExecutedSteps.remove(at: i)
                orders.append(step.letter)
                break
            }
        }
        
        print("Ordered steps execution for Day 7-1 is \(orders)")
    }
}

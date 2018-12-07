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
        
        var executionTime: Int {
            return Int(letter.unicodeScalars.first!.value) - 4
        }
    }
    
    class Worker {
        var task: (letter: Character, timeRemaining: Int)?
        
        var isAvailable: Bool {
            return task == nil
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
        
        // Keep track of what have been executed.
        var timeSpent = 0
        nonExecuted = Set(steps.keys)
        var nonStartedSteps = steps.values.sorted(by: { return $0.letter < $1.letter })
        
        // We create workers
        var workers = [Worker]()
        for _ in 0..<5 {
            workers.append(Worker())
        }
        
        while (!nonExecuted.isEmpty) {
            // Assign tasks to the workers, and find the time it'll take to finish the first one.
            workerLoop: for worker in workers.filter({ $0.isAvailable }) {
                for (i, step) in nonStartedSteps.enumerated() {
                    if !step.requirements.filter({ nonExecuted.contains($0) }).isEmpty {
                        continue
                    }
                    // Assign the task to the worker
                    worker.task = (letter: step.letter, timeRemaining: step.executionTime)
                    nonStartedSteps.remove(at: i)
                    continue workerLoop
                }
            }
            
            
            // Find the min time to advance
            let nextIncrement = workers
                .compactMap({ $0.task?.timeRemaining })
                .sorted()
                .first!
            
            // Task are assigned, advance the time by the min found
            timeSpent += nextIncrement
            
            // Find the tasks that have ended and carry on!
            workers.forEach({
                $0.task?.timeRemaining -= nextIncrement
                guard let task = $0.task else {
                    return
                }
                
                if task.timeRemaining <= 0 {
                    let letter = task.letter
                    nonExecuted.remove(letter)
                    $0.task = nil
                }
            })
        }
        
        print("Time of execution with 5 workers for Day 7-2 is \(timeSpent)s")
    }
}

//
//  Day5.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 05/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day5: Day {
    
    static func reduce(string: String) -> String {
        var string = string
        var i = string.startIndex
        while (i < string.index(before: string.endIndex)) {
            let a = Int(string[i].unicodeScalars.first!.value)
            let b = Int(string[string.index(after: i)].unicodeScalars.first!.value)
            
            if abs(a - b) == 32 {
                // Capitals and simple are separated from 32 unicode numbers exactly
                // We remove the elements, and we keep going
                string.remove(at: string.index(after: i))
                string.remove(at: i)
                // We move backward (if possible)
                if i != string.startIndex {
                    i = string.index(before: i)
                }
            } else {
                // We move forward
                i = string.index(after: i)
            }
        }
        return string
    }
    
    static func run() {
        let input = try! Input.get("day5.txt")
        
        let string = input.components(separatedBy: .newlines).first!
        print(string.count)
        
        let polymer = reduce(string: string)
        print("Left over of the polymer for Day 5-1 is \(polymer.count)")
        
        // Okay, let's remove one type each time, and keep track of the shortest
        var shortest = Int.max
        for i in Character("A").unicodeScalars.first!.value...Character("Z").unicodeScalars.first!.value {
            let substring = polymer.filter {
                let scalar = $0.unicodeScalars.first!.value
                return (scalar != i) && (scalar != i + 32)
            }
            let subpolymer = reduce(string: substring)
            shortest = min(shortest, subpolymer.count)
        }
        
        print("The shortest polymer that can be made for Day 5-2 is \(shortest)")
    }
}

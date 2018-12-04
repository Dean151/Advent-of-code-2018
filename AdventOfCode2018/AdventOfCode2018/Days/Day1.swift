//
//  Day1.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 04/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day1 {
    
    enum Change {
        case add(value: Int)
        case remove(value: Int)
        
        func perform(on currentValue: Int) -> Int {
            switch self {
            case .add(value: let value):
                return currentValue + value
            case .remove(value: let value):
                return currentValue - value
            }
        }
        
        static func from(string: String) -> Change? {
            guard let sign = string.first, let value = Int(string.dropFirst()) else {
                return nil
            }
            switch sign {
            case "+":
                return .add(value: value)
            case "-":
                return .remove(value: value)
            default:
                return nil
            }
        }
    }
    
    static func run() {
        let input = try! Input.get("day1.txt")
        let changes = input.components(separatedBy: .newlines).compactMap { return Change.from(string: $0) }
        var frequency = 0
        
        var tracker = Set<Int>([frequency])
        var firstDouble: Int?
        var finalFrequency: Int?
        
        while (firstDouble == nil) {
            for change in changes {
                frequency = change.perform(on: frequency)
                let (inserted, _) = tracker.insert(frequency)
                if !inserted {
                    firstDouble = frequency
                    break
                }
            }
            if finalFrequency == nil {
                finalFrequency = frequency
            }
        }
        
        print("Final frequency for Day 1-1 is \(finalFrequency!)")
        print("First double frequency for Day 1-2 is \(firstDouble!)")
        

    }
}

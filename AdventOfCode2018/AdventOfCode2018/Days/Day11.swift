//
//  Day11.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 11/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day11: Day {
    
    struct Square: Hashable {
        let index: Int
        let length: Int
    }
    
    class Grid {
        let powerLevel: [Int: Int]
        
        static func index(x: Int, y: Int) -> Int {
            return (y - 1) * 300 + (x - 1)
        }
        
        init(serialNumber: Int) {
            var levels = [Int: Int](minimumCapacity: 300*300)
            for x in 1...300 {
                for y in 1...300 {
                    let index = Grid.index(x: x, y: y)
                    let power = ((((x + 10) * y + serialNumber) * (x + 10) / 100) % 10) - 5
                    levels.updateValue(power, forKey: index)
                }
            }
            self.powerLevel = levels
        }
        
        func calculateMax(lengths: ClosedRange<Int>) -> (x: Int, y: Int, length: Int) {
            
            var currentMaxResult = (x: 0, y: 0, length: 0)
            var currentMax = Int.min
            
            for y in 1...300 {
                for x in 1...300 {
                    let lengthsRange = 1...min(301-x, 301-y)
                    if (!lengthsRange.overlaps(lengths)) {
                        continue
                    }
                    var power = 0
                    for length in lengthsRange.clamped(to: lengths) {
                        power += outerSquareSum(of: length, at: (x: x, y: y))
                        if power > currentMax {
                            currentMax = power
                            currentMaxResult = (x: x, y: y, length: length)
                        }
                    }
                }
            }
            
            return currentMaxResult
        }
        
        func outerSquareSum(of length: Int, at coords: (x: Int, y: Int)) -> Int {
            if length == 1 {
                return powerLevel[Grid.index(x: coords.x, y: coords.y)]!
            }
            var power = powerLevel[Grid.index(x: coords.x + length - 1, y: coords.y + length - 1 )]!
            for i in 0...length-2 {
                power += powerLevel[Grid.index(x: coords.x + i, y: coords.y + length - 1)]!
                power += powerLevel[Grid.index(x: coords.x + length - 1, y: coords.y + i)]!
            }
            return power
        }
        
    }
    
    static func run(input: String) {
        let serialNumber = Int(input.components(separatedBy: .whitespacesAndNewlines).first!)!
        let grid = Grid(serialNumber: serialNumber)
        
        let max3x3 = grid.calculateMax(lengths: 1...3)
        print("The 3x3 square with max power for Day 11-1 is \(max3x3.x),\(max3x3.y)")
        
        // We can expect the max size to be within 1...25
        // Based on the examples given
        let maxAny = grid.calculateMax(lengths: 1...25)
        print("The square with max power for Day 11-2 is \(maxAny.x),\(maxAny.y),\(maxAny.length)")
    }
}

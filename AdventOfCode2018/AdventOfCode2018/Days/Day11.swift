//
//  Day11.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 11/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day11: Day {
    
    class Grid {
        let offset = (x: 1, y: 1)
        let height = 300
        let width = 300
        
        var powerLevel = [Int: Int](minimumCapacity: 300*300)
        var powerLevel3x3 = [Int: Int](minimumCapacity: 300*300)
        
        func index(x: Int, y: Int) -> Int {
            return (y - offset.y) * width + (x - offset.x)
        }
        
        func coords(at index: Int) -> (x: Int, y: Int) {
            let x = index % width + offset.x
            let y = ((index - (index % width)) / width) + offset.y
            return (x: x, y: y)
        }
        
        func calculate(for serialNumber: Int) {
            powerLevel.removeAll()
            powerLevel3x3.removeAll()
            
            for y in 1...298 {
                for x in 1...298 {
                    let index = self.index(x: x, y: y)
                    powerLevel3x3[index] = get3x3Power(at: (x: x, y: y), for: serialNumber)
                }
            }
        }
        
        func get3x3Power(at coords: (x: Int, y: Int), for serialNumber: Int) -> Int {
            var power = 0
            for y in coords.y...coords.y+2 {
                for x in coords.x...coords.x+2 {
                    power += getPower(at: (x: x, y: y), for: serialNumber)
                }
            }
            return power
        }
        
        func getPower(at coords: (x: Int, y: Int), for serialNumber: Int) -> Int {
            let index = self.index(x: coords.x, y: coords.y)
            if let power = powerLevel[index] {
                return power
            }
            // We calculate
            let rackId = coords.x + 10
            let power = (((rackId * coords.y + serialNumber) * rackId / 100) % 10) - 5
            powerLevel[index] = power
            return power
        }
        
        var max3x3power: (x: Int, y: Int, power: Int) {
            let max = powerLevel3x3.max(by: { $0.value < $1.value })!
            let coords = self.coords(at: max.key)
            return (x: coords.x, y: coords.y, power: max.value)
        }
    }
    
    static func run(input: String) {
        let serialNumber = Int(input.components(separatedBy: .whitespacesAndNewlines).first!)!
        let grid = Grid()
        grid.calculate(for: serialNumber)
        let max = grid.max3x3power
        print("The top left corner of the max of 3x3 power for Day 11-1 is \(max.x),\(max.y)")
    }
}

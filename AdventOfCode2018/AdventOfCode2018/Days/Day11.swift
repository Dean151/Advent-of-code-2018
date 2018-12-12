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
        let powerSummedAreaTable: [Int: Int]
        
        static func index(x: Int, y: Int) -> Int {
            if x < 1 || y < 1 || x > 300 || y > 300 {
                return Int.min
            }
            return (y - 1) * 300 + (x - 1)
        }
        
        init(serialNumber: Int) {
            var summedAreaTable = [Int: Int](minimumCapacity: 300*300)
            for y in 1...300 {
                for x in 1...300 {
                    let power = ((((x + 10) * y + serialNumber) * (x + 10) / 100) % 10) - 5
                    let b = summedAreaTable[Grid.index(x: x, y: y-1)] ?? 0
                    let c = summedAreaTable[Grid.index(x: x-1, y: y)] ?? 0
                    let d = summedAreaTable[Grid.index(x: x-1, y: y-1)] ?? 0
                    summedAreaTable.updateValue(power + b + c - d, forKey: Grid.index(x: x, y: y))
                }
            }
            self.powerSummedAreaTable = summedAreaTable
        }
        
        func squareSum(of length: Int, at coords: (x: Int, y: Int)) -> Int {
            let start = (x: coords.x - 1, y: coords.y - 1)
            let end = (x: coords.x + length - 1, y: coords.y + length - 1)
            let topLeft = powerSummedAreaTable[Grid.index(x: start.x, y: start.y)] ?? 0
            let topRight = powerSummedAreaTable[Grid.index(x: start.x, y: end.y)] ?? 0
            let bottomLeft = powerSummedAreaTable[Grid.index(x: end.x, y: start.y)] ?? 0
            let bottomRight = powerSummedAreaTable[Grid.index(x: end.x, y: end.y)] ?? 0
            return topLeft + bottomRight - topRight - bottomLeft
        }
        
    }
    
    static func run(input: String) {
        let serialNumber = Int(input.components(separatedBy: .whitespacesAndNewlines).first!)!
        let grid = Grid(serialNumber: serialNumber)
        
        var currentMax = (x: 0, y: 0, length: 0, value: Int.min)
        
        for length in 1...300 {
            let max = 301 - length
            for y in 1...max {
                for x in 1...max {
                    let power = grid.squareSum(of: length, at: (x: x, y: y))
                    if power > currentMax.value {
                        currentMax = (x: x, y: y, length: length, value: power)
                    }
                }
            }
            
            if length == 3 {
                print("The 3x3 square with max power for Day 11-1 is \(currentMax.x),\(currentMax.y)")
            }
        }
        
        print("The square with max power for Day 11-2 is \(currentMax.x),\(currentMax.y),\(currentMax.length)")
    }
}

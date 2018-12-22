//
//  File.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 22/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day22: Day {
    
    typealias Position = (x: Int, y: Int)
    
    struct Cavern {
        
        enum Region: Int, CustomStringConvertible {
            case rocky = 0, wet, narrow
            
            var description: String {
                switch self {
                case .rocky:
                    return "."
                case .wet:
                    return "="
                case .narrow:
                    return "|"
                }
            }
        }
        
        let width: Int
        let height: Int
        let target: Position
        let regions: [Int: Region]
        
        static func index(at pos: Position, width: Int) -> Int {
            return pos.y * width + pos.x
        }
        
        func index(at pos: Position) -> Int {
            return Cavern.index(at: pos, width: width)
        }
        
        init(target: Position, depth: Int) {
            let width = target.x + 10
            let height = target.y + 10
            
            let capacity = width * height
            var erosions = [Int: Int](minimumCapacity: capacity)
            var regions = [Int: Region](minimumCapacity: capacity)
            
            for y in 0...target.y {
                for x in 0...target.x {
                    let index = Cavern.index(at: (x: x, y: y), width: width)
                    let geoIndex: Int
                    if (x == 0 && y == 0) || (x == target.x && y == target.y) {
                        geoIndex = 0
                    } else if y == 0 {
                        geoIndex = 16807 * x
                    } else if x == 0 {
                        geoIndex = 48271 * y
                    } else {
                        geoIndex = erosions[index - width]! * erosions[index - 1]!
                    }
                    let erosion = (geoIndex + depth) % 20183
                    erosions[index] = erosion
                    regions[index] = Region(rawValue: erosion % 3)!
                }
            }
            
            self.width = width
            self.height = height
            self.target = target
            self.regions = regions
        }
        
        var riskLevel: Int {
            return regions.reduce(0, { $0 + ($1.key <= index(at: target) ? $1.value.rawValue : 0) })
        }
    }
    
    static func run(input: String) {
        // Extract stuff from the input
        let components = input.components(separatedBy: .newlines).compactMap({ !$0.isEmpty ? $0.components(separatedBy: .whitespaces).last : nil })
        let depth = Int(components.first!)!
        let coords = components.last!.components(separatedBy: ",").compactMap({ Int($0) })
        let target = (x: coords.first!, y: coords.last!)
        
        assert(Cavern(target: (x: 10, y: 10), depth: 510).riskLevel == 114)
        let cavern = Cavern(target: target, depth: depth)
        print("Risk level of the cavern for Day 21-1 is \(cavern.riskLevel)")
    }
}

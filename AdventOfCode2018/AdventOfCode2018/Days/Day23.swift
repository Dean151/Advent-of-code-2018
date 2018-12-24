//
//  Day23.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 23/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day23: Day {
    
    typealias Position = (x: Int, y: Int, z: Int)
    
    struct Nanobot {
        let position: Position
        let range: Int
        
        static func from(string: String) -> Nanobot? {
            // pos=<10573027,54782809,49932958>, r=97928881
            let components = string.components(separatedBy: ", ").compactMap({ $0.components(separatedBy: "=").last })
            guard components.count == 2 else {
                return nil
            }
            guard let range = Int(components.last!) else {
                return nil
            }
            let coords = components.first!.dropFirst().dropLast().components(separatedBy: ",").compactMap({ Int($0) })
            guard coords.count == 3 else {
                return nil
            }
            return Nanobot(position: (x: coords[0], y: coords[1], z: coords[2]), range: range)
        }
    }
    
    static func distance(from a: Position, to b: Position) -> Int {
        return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)
    }
    
    static func distance(fromOriginTo a: Position) -> Int {
        return distance(from: (x: 0, y: 0, z: 0), to: a)
    }
    
    static func bots(from input: String) -> [Nanobot] {
        return input.components(separatedBy: .newlines).compactMap({ Nanobot.from(string: $0) })
    }
    
    static func inRangeFromBiggestRange(with bots: [Nanobot]) -> Int {
        let mainBot = bots.max(by: { $0.range < $1.range })!
        let inRange = bots.filter({ distance(from: $0.position, to: mainBot.position) <= mainBot.range })
        return inRange.count
    }
    
    static func mostInRangePointDistance(with bots: [Nanobot]) -> Int {
        let point = (x: 0, y: 0, z: 0) // TODO!
        return distance(fromOriginTo: point)
    }
    
    static func run(input: String) {
        let nanobots = bots(from: input)
        
        let example = "pos=<0,0,0>, r=4\npos=<1,0,0>, r=1\npos=<4,0,0>, r=3\npos=<0,2,0>, r=1\npos=<0,5,0>, r=3\npos=<0,0,3>, r=1\npos=<1,1,1>, r=1\npos=<1,1,2>, r=1\npos=<1,3,1>, r=1"
        assert(inRangeFromBiggestRange(with: bots(from: example)) == 7)
        print("Number of bots in range for Day 23-1 is \(inRangeFromBiggestRange(with: nanobots))")
        
        let example2 = "pos=<10,12,12>, r=2\npos=<12,14,12>, r=2\npos=<16,12,12>, r=4\npos=<14,14,14>, r=6\npos=<50,50,50>, r=200\npos=<10,10,10>, r=5"
        assert(mostInRangePointDistance(with: bots(from: example2)) == 36)
        print("Distance from most \"in-range\" point for Day 23-2 is \(mostInRangePointDistance(with: nanobots))")
    }
}

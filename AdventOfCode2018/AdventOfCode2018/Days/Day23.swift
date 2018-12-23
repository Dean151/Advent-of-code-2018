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
    
    static func run(input: String) {
        let nanobots = input.components(separatedBy: .newlines).compactMap({ Nanobot.from(string: $0) })
        
        // Find the max range
        let mainBot = nanobots.max(by: { $0.range < $1.range })!
        let inRange = nanobots.filter({ distance(from: $0.position, to: mainBot.position) <= mainBot.range })
        print("Number of bots in range for Day 23-1 is \(inRange.count)")
    }
}

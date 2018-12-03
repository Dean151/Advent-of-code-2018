//
//  day3.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 03/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day3 {
    
    struct Plan: Sequence {
        let number: Int
        
        let x: Int
        let y: Int
        
        let width: Int
        let height: Int
        
        static let regex = try! NSRegularExpression(pattern: "^#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)$", options: .caseInsensitive)
        
        init?(from string: String) {
            let matches = Plan.regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let match = matches.first else {
                return nil
            }
            
            let number = Int(match.group(at: 1, in: string))!
            self.number = number
            
            self.x = Int(match.group(at: 2, in: string))!
            self.y = Int(match.group(at: 3, in: string))!
            
            self.width = Int(match.group(at: 4, in: string))!
            self.height = Int(match.group(at: 5, in: string))!
        }
        
        func makeIterator() -> Plan.Iterator {
            return Iterator(self)
        }
        
        struct Iterator: IteratorProtocol {
            let plan: Plan
            var index = 0
            
            init(_ plan: Plan) {
                self.plan = plan
            }
            
            mutating func next() -> Int? {
                guard index < plan.width * plan.height else {
                    return nil
                }
                let x = plan.x + (index % plan.width)
                let y = plan.y + (index / plan.width)
                index += 1
                return (2000 * y) + x
            }
        }
    }
    
    static func run() {
        let homePath = FileManager.default.homeDirectoryForCurrentUser
        let inputPath = "Developer/Autres/Advent-of-code-2018/AdventOfCode2018/AdventOfCode2018/day3.txt"
        let inputUrl = homePath.appendingPathComponent(inputPath)
        let inputData = try! Data(contentsOf: inputUrl)
        let input = String(data: inputData, encoding: .utf8)!
        
        let plans = input.components(separatedBy: .newlines).compactMap({ Plan(from: $0) })
        
        // Just keep tracking of multiple used squares
        var used = [Int: Int]()
        var reused = Set<Int>()
        var integral = Set<Int>()
        
        for plan in plans {
            var isIntegral = true
            for index in plan {
                if let number = used[index] {
                    isIntegral = false
                    integral.remove(number)
                    reused.insert(index)
                }
                used[index] = plan.number
            }
            if isIntegral {
                integral.insert(plan.number)
            }
        }
        
        let nbUsedMoreThanOnce = reused.count
        print("There were \(nbUsedMoreThanOnce) square inches in conflicts for Day 3-1")
        
        print("Found sheets numbers that are complete for Day 3-2: \(integral)")
    }
}

extension NSTextCheckingResult {
    func group(at index: Int, in string: String) -> String {
        let range = self.range(at: index)
        return (string as NSString).substring(with: range)
    }
}

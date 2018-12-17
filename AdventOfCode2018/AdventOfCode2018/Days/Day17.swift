//
//  Day17.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 17/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day17: Day {
    
    typealias Position = (x: Int, y: Int)
    
    class Slice: CustomStringConvertible {
        
        enum Ground: CustomStringConvertible {
            case sand, clay
            case waterfall, restingwater
            
            var description: String {
                switch self {
                case .sand:
                    return "."
                case .clay:
                    return "#"
                case .waterfall:
                    return "|"
                case .restingwater:
                    return "~"
                }
            }
        }
        
        let offset: Position
        let height: Int
        let width: Int
        var groundSlices: [Ground]
        
        static func index(at pos: (x: Int, y: Int), width: Int, offset: Position) -> Int {
            return (pos.y - offset.y) * width + (pos.x - offset.x)
        }
        
        func index(at pos: (x: Int, y: Int)) -> Int {
            return Slice.index(at: pos, width: width, offset: offset)
        }
        
        func coords(at index: Int) -> (x: Int, y: Int) {
            let x = index % width + offset.x
            let y = ((index - (index % width)) / width) + offset.y
            return (x: x, y: y)
        }
        
        init(clays: [Int: [Int: Ground]]) {
            let yMax = clays.keys.max()!
            let (xMin,xMax) = clays.reduce((Int.max, Int.min), { return (min($0.0, $1.value.keys.min()!), max($0.1, $1.value.keys.max()!)) })
            
            self.offset = (x: xMin-1, y: 0)
            self.width = xMax - xMin + 3
            self.height = yMax + 1
            self.groundSlices = [Ground](repeating: .sand, count: width*height)
            
            for (y,subslice) in clays {
                for (x,ground) in subslice {
                    groundSlices[index(at: (x: x, y: y))] = ground
                }
            }
            
            groundSlices[index(at: (x: 500, y: 0))] = .waterfall
        }
        
        static func from(lines: [String]) -> Slice {
            let parseRegex = try! NSRegularExpression(pattern: "^(x|y)=(\\d+), (x|y)=(\\d+)\\.\\.(\\d+)$", options:  .caseInsensitive)
            
            var slices = [Int: [Int: Ground]]()
            for line in lines {
                guard let match = parseRegex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count)).first else {
                    print("Could not parse line \(line)")
                    continue
                }
                let a = match.group(at: 1, in: line)
                let b = Int(match.group(at: 2, in: line))!
                let c = match.group(at: 3, in: line)
                let d = Int(match.group(at: 4, in: line))!
                let e = Int(match.group(at: 5, in: line))!
                
                guard a == "x" && c == "y" || a == "y" || c == "x" else {
                    print("Could not parse line \(line)")
                    continue
                }
                
                for i in d...e {
                    if a == "x" {
                        if slices[i] == nil {
                            slices[i] = [b: .clay]
                        } else {
                            slices[i]![b] = .clay
                        }
                    } else {
                        if slices[b] == nil {
                            slices[b] = [i: .clay]
                        } else {
                            slices[b]![i] = .clay
                        }
                    }
                }
            }
            
            return Slice(clays: slices)
        }
        
        var description: String {
            var string = ""
            for y in 0..<height {
                for x in offset.x..<width+offset.x {
                    string += groundSlices[index(at: (x: x, y: y))].description
                }
                string += "\n"
            }
            return string
        }
    }
    
    static func run(input: String) {
        let slice = Slice.from(lines: input.components(separatedBy: .newlines))
        print(slice)
    }
}

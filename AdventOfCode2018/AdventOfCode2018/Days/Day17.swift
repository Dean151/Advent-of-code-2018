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
            case sand, clay, watered, waterfalling, source
            
            var description: String {
                switch self {
                case .sand:
                    return "."
                case .clay:
                    return "#"
                case .watered:
                    return "~"
                case .waterfalling:
                    return "|"
                case .source:
                    return "+"
                }
            }
        }
        
        let offset: Position
        let height: Int
        let width: Int
        var ground: [Ground]
        
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
        
        func up(from index: Int) -> Int {
            return index - width
        }
        
        func left(from index: Int) -> Int {
            return index - 1
        }
        
        func right(from index: Int) -> Int {
            return index + 1
        }
        
        func down(from index: Int) -> Int {
            return index + width
        }
        
        init(clays: [Int: [Int: Ground]]) {
            let yMax = clays.keys.max()!
            let (xMin,xMax) = clays.reduce((Int.max, Int.min), { return (min($0.0, $1.value.keys.min()!), max($0.1, $1.value.keys.max()!)) })
            
            self.offset = (x: xMin-1, y: 0)
            self.width = xMax - xMin + 3
            self.height = yMax + 1
            self.ground = [Ground](repeating: .sand, count: width*height)
            
            for (y,subslice) in clays {
                for (x,ground) in subslice {
                    self.ground[index(at: (x: x, y: y))] = ground
                }
            }
        }
        
        static func from(lines: [String]) -> Slice {
            let parseRegex = try! NSRegularExpression(pattern: "^(x|y)=(\\d+), (x|y)=(\\d+)\\.\\.(\\d+)$", options:  .caseInsensitive)
            
            var ground = [Int: [Int: Ground]]()
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
                        if ground[i] == nil {
                            ground[i] = [b: .clay]
                        } else {
                            ground[i]![b] = .clay
                        }
                    } else {
                        if ground[b] == nil {
                            ground[b] = [i: .clay]
                        } else {
                            ground[b]![i] = .clay
                        }
                    }
                }
            }
            
            return Slice(clays: ground)
        }
        
        var description: String {
            var string = ""
            for y in 0..<height {
                for x in offset.x..<width+offset.x {
                    let index = self.index(at: (x: x, y: y))
                    string += ground[index].description
                }
                string += "\n"
            }
            return string
        }
        
        func startFlooding(from pos: Position) {
            let index = self.index(at: pos)
            var currentFloodings = Set<Int>([index])
            
            while !currentFloodings.isEmpty {
                for current in currentFloodings {
                    defer {
                        currentFloodings.remove(current)
                    }
                    
                    ground[current] = .waterfalling
                    
                    let down = self.down(from: current)
                    if down >= (width*height) {
                        // Out of bounds!
                        continue
                    }
                    
                    switch ground[down] {
                    case .sand:
                        currentFloodings.insert(down)
                    case .clay, .watered:
                        let flooding = floodLine(from: current)
                        if flooding.count > 0 {
                            currentFloodings.formUnion(flooding)
                        } else {
                            // Go back up to fill stuff
                            currentFloodings.insert(up(from: current))
                        }
                    case .waterfalling:
                        continue
                    case .source:
                        fatalError("Impossible Oo")
                    }
                }
            }
            
            ground[index] = .source
        }
        
        func floodLine(from index: Int) -> [Int] {
            var flooding: [Int] = []
            
            ground[index] = .waterfalling
            
            // First flood left
            var left = self.left(from: index)
            while ground[left] != .clay {
                ground[left] = .waterfalling
                let down = self.down(from: left)
                if ground[down] == .sand {
                    flooding.append(left)
                    break
                }
                left = self.left(from: left)
            }
            
            // Then right
            var right = self.right(from: index)
            while ground[right] != .clay {
                ground[right] = .waterfalling
                let down = self.down(from: right)
                if ground[down] == .sand {
                    flooding.append(right)
                    break
                }
                right = self.right(from: right)
            }
            
            if flooding.isEmpty {
                // It's watered
                for i in left+1...right-1 {
                    ground[i] = .watered
                }
            }
            
            return flooding
        }
    }
    
    static func run(input: String) {
        let slice = Slice.from(lines: input.components(separatedBy: .newlines))
        slice.startFlooding(from: (x: 500, y: 0))
        print(slice)
        print("Number of flooded tiles for Day 17-1 is \(slice.ground.filter({ [.watered, .waterfalling].contains($0) }).count)")
    }
}

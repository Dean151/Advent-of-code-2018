//
//  Day18.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 18/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day18: Day {
    
    typealias Position = (x: Int, y: Int)
    
    enum Acre: CustomStringConvertible {
        case open, wooded, lumberyard
        
        var description: String {
            switch self {
            case .open:
                return "."
            case .wooded:
                return "|"
            case .lumberyard:
                return "#"
            }
        }
    }
    
    class Field: CustomStringConvertible {
        let width: Int
        let height: Int
        var field: [Acre]
        
        init(width: Int, height: Int, field: [Acre]) {
            self.width = width
            self.height = height
            self.field = field
        }
        
        static func index(at pos: Position, width: Int) -> Int {
            return pos.y * width + pos.x
        }
        
        func index(at pos: Position) -> Int {
            return Field.index(at: pos, width: width)
        }
        
        func position(at index: Int) -> Position {
            let x = index % width
            let y = ((index - (index % width)) / width)
            return (x: x, y: y)
        }
        
        func neighbors(around pos: Position) -> [Position] {
            return [
                (x: pos.x-1, y: pos.y-1),
                (x: pos.x, y: pos.y-1),
                (x: pos.x+1, y: pos.y-1),
                (x: pos.x+1, y: pos.y),
                (x: pos.x-1, y: pos.y+1),
                (x: pos.x, y: pos.y+1),
                (x: pos.x+1, y: pos.y+1),
                (x: pos.x-1, y: pos.y),
            ].filter({ (x, y) in
                return x >= 0 && y >= 0 && x < width && y < height
            })
        }
        
        func neighbors(around index: Int) -> [Int] {
            return neighbors(around: position(at: index)).map { self.index(at: $0) }
        }
        
        func neighborsOfType(around index: Int) -> (open: Int, wooded: Int, lumberyard: Int) {
            var open = 0, wooded = 0, lumberyard = 0
            for index in neighbors(around: index) {
                switch field[index] {
                case .open:
                    open += 1
                case .wooded:
                    wooded += 1
                case .lumberyard:
                    lumberyard += 1
                }
            }
            return (open, wooded, lumberyard)
        }
        
        func newAcre(from acre: Acre, with count: (open: Int, wooded: Int, lumberyard: Int)) -> Acre? {
            switch acre {
            case .open:
                return count.wooded >= 3 ? .wooded : nil
            case .wooded:
                return count.lumberyard >= 3 ? .lumberyard : nil
            case .lumberyard:
                return count.wooded == 0 || count.lumberyard == 0 ? .open : nil
            }
        }
        
        func runOnce() {
            let counts = [Int](0..<width*height).map({ self.neighborsOfType(around: $0) })
            for i in 0..<width*height {
                if let new = newAcre(from: field[i], with: counts[i]) {
                    field[i] = new
                }
            }
        }
        
        func run(n: Int) {
            for _ in 0..<n {
                runOnce()
                print(self)
            }
        }
        
        var checksum: Int {
            let nbWooded = field.filter({ $0 == .wooded }).count
            let nbLumberyard = field.filter({ $0 == .lumberyard }).count
            return nbLumberyard * nbWooded
        }
        
        static func from(lines: [String]) -> Field {
            let width = lines.first!.count, height = lines.count
            var acres = [Acre](repeating: .open, count: width * height)
            for (y, line) in lines.enumerated() {
                for (x, c) in line.enumerated() {
                    let index = Field.index(at: (x: x, y: y), width: width)
                    switch c {
                    case "#":
                        acres[index] = .lumberyard
                    case "|":
                        acres[index] = .wooded
                    default:
                        break
                    }
                }
            }
            
            return Field(width: width, height: height, field: acres)
        }
        
        var description: String {
            var string = ""
            for y in 0..<height {
                for x in 0..<width {
                    string += field[index(at: (x: x, y: y))].description
                }
                string += "\n"
            }
            return string
        }
    }
    
    static func run(input: String) {
        let field = Field.from(lines: input.components(separatedBy: .newlines).filter({ !$0.isEmpty }))
        print(self)
        field.run(n: 10)
        print("Solution for Day 18-1 is \(field.checksum)")
        field.run(n: 1000000000 - 10)
        print("Solution for Day 18-2 is \(field.checksum)")
    }
}

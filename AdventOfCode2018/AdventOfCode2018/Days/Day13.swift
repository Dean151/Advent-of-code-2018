//
//  Day13.swift
//  AdventOfCode2018
//
//  Created by Thomas DURAND on 13/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day13: Day {
    
    typealias Position = (x: Int, y: Int)
    
    class Track: CustomStringConvertible {
        
        enum Section: CustomStringConvertible {
            enum StraightType {
                case horizontal, vertical
            }
            enum curveType {
                case topLeft, topRight, bottomLeft, bottomRight
            }
            
            case straight(type: StraightType), curve(type: curveType), intersection
            
            var description: String {
                switch self {
                case .intersection:
                    return "+"
                case .straight(type: let type):
                    switch type {
                    case .horizontal:
                        return "-"
                    case .vertical:
                        return "|"
                    }
                case .curve(type: let type):
                    switch type {
                    case .topLeft, .bottomRight:
                        return "/"
                    case .bottomLeft, .topRight:
                        return "\\"
                    }
                }
            }
            
            static func from(char: Character, previous: Character?) -> Section? {
                switch char {
                case "-":
                    return .straight(type: .horizontal)
                case "|":
                    return .straight(type: .vertical)
                case "+":
                    return .intersection
                case "/":
                    return .curve(type: previous == "-" || previous == "+" ? .bottomRight : .topLeft)
                case "\\":
                    return .curve(type: previous == "-" || previous == "+" ? .topRight : .bottomLeft)
                default:
                    return nil
                }
            }
        }
        
        class Kart {
            
            enum Direction {
                case up, right, down, left
            }
            
            var position: Position
            var direction: Direction
            
            var nextTurnIsLeft = true
            
            init(position: Position, direction: Direction) {
                self.position = position
                self.direction = direction
            }
            
            static func from(char: Character, at position: Position) -> Kart? {
                switch char {
                case "^":
                    return Kart(position: position, direction: .up)
                case ">":
                    return Kart(position: position, direction: .right)
                case "v":
                    return Kart(position: position, direction: .down)
                case "<":
                    return Kart(position: position, direction: .left)
                default:
                    return nil
                }
            }
        }
        
        let width: Int
        let height: Int
        let sections: [Int: Section]
        let karts: [Kart]
        
        init(width: Int, height: Int, sections: [Int: Section], karts: [Kart]) {
            self.width = width
            self.height = height
            self.sections = sections
            self.karts = karts
        }
        
        static func index(for pos: Position, in width: Int) -> Int {
            return pos.y * width + pos.x
        }
        
        func index(for pos: Position) -> Int {
            return Track.index(for: pos, in: width)
        }
        
        var description: String {
            var string = ""
            for y in 0..<height {
                for x in 0..<width {
                    let index = self.index(for: (x: x, y: y))
                    string += self.sections[index]?.description ?? " "
                }
                string += "\n"
            }
            return string
        }
        
        static func parse(input: String) -> Track {
            let lines = input.components(separatedBy: .newlines)
            
            // Get width and height
            let height = lines.count, width = lines.max(by: { $0.count < $1.count })!.count
            
            var sections = [Int: Section](minimumCapacity: width*height)
            var karts = [Kart]()
            
            // Now we parse each character.
            for (y,line) in lines.enumerated() {
                var previous: Character?
                for (x,c) in line.enumerated() {
                    if c == " " {
                        continue
                    }
                    
                    // Is there a kart?
                    var c = c
                    if let kart = Kart.from(char: c, at: (x: x, y: y)) {
                        karts.append(kart)
                        c = [.up, .down].contains(kart.direction) ? "|" : "-"
                    }
                    
                    // Parse the section
                    if let section = Section.from(char: c, previous: previous) {
                        sections[Track.index(for: (x: x, y: y), in: width)] = section
                    }
                    
                    previous = c
                }
            }
            
            return Track(width: width, height: height, sections: sections, karts: karts)
        }
    }
    
    static func run(input: String) {
        let track = Track.parse(input: input)
        print(track)
    }
}

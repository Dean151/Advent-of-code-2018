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
    
    class Track {
        
        enum Section {
            enum StraightType {
                case horizontal, vertical
            }
            enum curveType {
                case topLeft, topRight, bottomLeft, bottomRight
            }
            
            case straight(type: StraightType), curve(type: curveType), intersection
            
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
        
        enum Direction {
            case up, right, down, left
        }
        
        class Kart: Equatable, Hashable {
            
            enum NextIntersectionType {
                case left, straight, right
            }
            
            let index: Int
            var direction: Direction
            var nextIntersection = NextIntersectionType.left
            
            init(index: Int, direction: Direction) {
                self.index = index
                self.direction = direction
            }
            
            func updateDirection(following section: Section) {
                switch section {
                case .straight:
                    break
                case .curve(type: let type):
                    switch type {
                    case .topLeft:
                        if direction == .up {
                            turnRight()
                        } else if direction == .left {
                            turnLeft()
                        } else {
                            fatalError("Out of track")
                        }
                    case .topRight:
                        if direction == .right {
                            turnRight()
                        } else if direction == .up {
                            turnLeft()
                        } else {
                            fatalError("Out of track")
                        }
                    case .bottomLeft:
                        if direction == .left {
                            turnRight()
                        } else if direction == .down {
                            turnLeft()
                        } else {
                            fatalError("Out of track")
                        }
                    case .bottomRight:
                        if direction == .down {
                            turnRight()
                        } else if direction == .right {
                            turnLeft()
                        } else {
                            fatalError("Out of track")
                        }
                    }
                case .intersection:
                    switch nextIntersection {
                    case .left:
                        self.turnLeft()
                        nextIntersection = .straight
                    case .straight:
                        nextIntersection = .right
                    case .right:
                        self.turnRight()
                        nextIntersection = .left
                    }
                }
            }
            
            func turnLeft() {
                switch direction {
                case .up:
                    direction = .left
                case .left:
                    direction = .down
                case .down:
                    direction = .right
                case .right:
                    direction = .up
                }
            }
            
            func turnRight() {
                switch direction {
                case .up:
                    direction = .right
                case .right:
                    direction = .down
                case .down:
                    direction = .left
                case .left:
                    direction = .up
                }
            }
            
            static func from(index: Int, char: Character) -> Kart? {
                switch char {
                case "^":
                    return Kart(index: index, direction: .up)
                case ">":
                    return Kart(index: index, direction: .right)
                case "v":
                    return Kart(index: index, direction: .down)
                case "<":
                    return Kart(index: index, direction: .left)
                default:
                    return nil
                }
            }
            
            var hashValue: Int {
                return index
            }
            
            static func == (lhs: Kart, rhs: Kart) -> Bool {
                return lhs.index == rhs.index
            }
        }
        
        let width: Int
        let height: Int
        let sections: [Int: Section]
        var karts: [Kart: Int]
        
        init(width: Int, height: Int, sections: [Int: Section], karts: [Kart: Int]) {
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
        
        func position(at index: Int) -> Position {
            return (x: index % width, y: (index - (index % width))/width)
        }
        
        func nextPosition(from position: Position, going direction: Direction) -> Position {
            switch direction {
            case .up:
                return (x: position.x, y: position.y - 1)
            case .right:
                return (x: position.x + 1, y: position.y)
            case .down:
                return (x: position.x, y: position.y + 1)
            case .left:
                return (x: position.x - 1, y: position.y)
            }
        }
        
        func nextIndex(from currentIndex: Int, going direction: Direction) -> Int {
            return index(for: nextPosition(from: position(at: currentIndex), going: direction))
        }
        
        func findNextCollision() -> (position: Position, karts: [Kart]) {
            while true {
                // Run each kart in the proper order :)
                var collision: (position: Position, karts: [Kart])?
                for (kart, currentIndex) in karts.sorted(by: { $0.value < $1.value }) {
                    let nextIndex = self.nextIndex(from: currentIndex, going: kart.direction)
                    
                    // Check the new index is not in conflict with another kart.
                    // If so, we've found our collision
                    if let secondKart = karts.filter({ $0.value == nextIndex }).first?.key {
                        collision = (position: self.position(at: nextIndex), karts: [kart, secondKart])
                    }
                    
                    // If the new position is a curve or a intersection, the direction changes
                    // Move the kart at the new position
                    kart.updateDirection(following: sections[nextIndex]!)
                    self.karts[kart] = nextIndex
                }
                if let collision = collision {
                    return collision
                }
            }
        }
        
        static func parse(input: String) -> Track {
            let lines = input.components(separatedBy: .newlines)
            
            // Get width and height
            let height = lines.count, width = lines.max(by: { $0.count < $1.count })!.count
            
            var sections = [Int: Section](minimumCapacity: width*height)
            var karts = [Kart: Int]()
            
            // Now we parse each character.
            for (y,line) in lines.enumerated() {
                var previous: Character?
                for (x,c) in line.enumerated() {
                    if c == " " {
                        continue
                    }
                    
                    let index = Track.index(for: (x: x, y: y), in: width)
                    
                    // Is there a kart?
                    var c = c
                    if let kart = Kart.from(index: index, char: c) {
                        karts[kart] = index
                        c = [.up, .down].contains(kart.direction) ? "|" : "-"
                    }
                    
                    // Parse the section
                    if let section = Section.from(char: c, previous: previous) {
                        sections[index] = section
                    }
                    
                    previous = c
                }
            }
            
            return Track(width: width, height: height, sections: sections, karts: karts)
        }
    }
    
    static func run(input: String) {
        let track = Track.parse(input: input)
        
        var firstRemoved = false
        while track.karts.count > 1 {
            let collision = track.findNextCollision()
            
            if !firstRemoved {
                print("First collision for Day 13-1 occurred at \(collision.position.x),\(collision.position.y)")
                firstRemoved = true
            }
            
            for kart in collision.karts {
                track.karts.removeValue(forKey: kart)
            }
        }
        
        if let kart = track.karts.first {
            let position = track.position(at: kart.value)
            print("The only remaining kart for Day 13-2 is at \(position.x),\(position.y)")
        } else {
            fatalError("No remaining kart...")
        }
    }
}

//
//  Day20.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 20/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day20: Day {
    
    struct Position: Hashable {
        var x: Int, y: Int
        
        var hashValue: Int {
            return "\(x),\(y)".hashValue
        }
    }
    
    class Facility {
        
        var squares = [Int: [Int: Square]]()
        
        var yMin: Int {
            return squares.keys.min() ?? 0
        }
        var yMax: Int {
            return squares.keys.max() ?? 0
        }
        var xMin: Int {
            return squares.mapValues({ $0.keys.min() ?? 0 }).values.min() ?? 0
        }
        var xMax: Int {
            return squares.mapValues({ $0.keys.max() ?? 0 }).values.max() ?? 0
        }
        
        var rooms = [Position: Int]()
        
        enum Square: String {
            case room = "."
            case door = "+"
            case wall = "#"
        }
        
        enum Direction: Character {
            case north = "N", west = "W", east = "E", south = "S"
        }
        
        subscript(pos: Position) -> Square {
            get {
                return squares[pos.y]?[pos.x] ?? .wall
            }
            set {
                if var line = squares[pos.y] {
                    line.updateValue(newValue, forKey: pos.x)
                    squares.updateValue(line, forKey: pos.y)
                } else {
                    squares.updateValue([pos.x: newValue], forKey: pos.y)
                }
            }
        }
        
        init(regex: String) {
            // Initialize stuff
            self[Position(x: 0, y: 0)] = .room
            rooms[Position(x: 0, y: 0)] = 0
            
            // We parse it twice to update distances with the minimum possible :)
            for _ in 1...2 {
                follow(regex: regex, initial: Position(x: 0, y: 0))
            }
        }
        
        func follow(regex: String, initial pos: Position) {
            var regex = regex
            var pos = pos
            var stackedPos = [Position]()
            while regex.count > 0 {
                let c = regex.removeFirst()
                if c == "^" {
                    continue
                } else if c == "$" {
                    break
                } else if let direction = Direction(rawValue: c) {
                    goThrewDoor(from: &pos, direction: direction)
                } else if c == "(" {
                    stackedPos.append(pos)
                } else if c == "|" {
                    pos = stackedPos.last!
                } else if c == ")" {
                    stackedPos.removeLast()
                } else {
                    fatalError("Case not handled")
                }
            }
        }
        
        func goThrewDoor(from pos: inout Position, direction: Direction) {
            let distance = rooms[pos] ?? 0
            move(from: &pos, direction: direction)
            self[pos] = .door
            move(from: &pos, direction: direction)
            self[pos] = .room
            
            if let oldDistance = rooms[pos] {
                rooms[pos] = min(distance + 1, oldDistance)
            } else {
                rooms[pos] = distance + 1
            }
        }
        
        func move(from pos: inout Position, direction: Direction) {
            switch direction {
            case .west:
                pos.x -= 1
            case .east:
                pos.x += 1
            case .north:
                pos.y -= 1
            case .south:
                pos.y += 1
            }
        }
        
        var fartest: Int {
            return rooms.values.max() ?? 0
        }
    }
    
    static func run(input: String) {
        let regex = input.components(separatedBy: .newlines).first!
        
        assert(Facility(regex: "^WNE$").fartest == 3)
        assert(Facility(regex: "^ENWWW(NEEE|SSE(EE|N))$").fartest == 10)
        assert(Facility(regex: "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$").fartest == 18)
        assert(Facility(regex: "^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$").fartest == 23)
        assert(Facility(regex: "^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$").fartest == 31)
        
        print("Max number of doors we can pass threw for Day 20-1 is \(Facility(regex: regex).fartest)")
        print("Number of rooms after 1000 doors at least for Day 20-2 is \(Facility(regex: regex).rooms.filter({ $0.value >= 1000 }).count)")
    }
}

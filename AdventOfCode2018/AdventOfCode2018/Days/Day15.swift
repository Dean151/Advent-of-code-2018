//
//  Day15.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 15/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day15: Day {
    
    typealias Position = (x: Int, y: Int)
    
    class Warrior: Equatable, Hashable {
        enum `Type` {
            case elf, goblin
        }
        
        let uuid = UUID()
        let type: Type
        let attack = 3
        var health = 200
        
        init(type: Type) {
            self.type = type
        }
        
        var hashValue: Int {
            return uuid.hashValue
        }
        
        func attack(other: Warrior) {
            other.health -= self.attack
        }
        
        static func == (lhs: Warrior, rhs: Warrior) -> Bool {
            return lhs.uuid == rhs.uuid
        }
    }
    
    class Cavern: CustomStringConvertible {
        enum Square {
            case wall, open
        }
        
        let width: Int
        let height: Int
        
        let squares: [Square]
        var warriors: [(warrior: Warrior, index: Int)]
        
        init(width: Int, height: Int, squares: [Square], warriors: [(warrior: Warrior, index: Int)]) {
            self.width = width
            self.height = height
            self.squares = squares
            self.warriors = warriors
        }
        
        static func index(for pos: Position, in width: Int) -> Int {
            return pos.y * width + pos.x
        }
        
        func index(for pos: Position) -> Int {
            return Cavern.index(for: pos, in: width)
        }
        
        func position(at index: Int) -> Position {
            return (x: index % width, y: (index - (index % width))/width)
        }
        
        func neighbors(around pos: Position) -> [Position] {
            return [
                (x: pos.x, y: pos.y-1),
                (x: pos.x-1, y: pos.y),
                (x: pos.x+1, y: pos.y),
                (x: pos.x, y: pos.y+1)
            ]
        }
        
        func openedNeighbors(around pos: Position) -> [Position] {
            return neighbors(around: pos).filter {
                let index = self.index(for: $0)
                return squares[index] == .open && !warriors.contains(where: { $0.index == index && $0.warrior.health > 0 })
            }
        }
        
        func firstTargetToAttack(targets: [(warrior: Day15.Warrior, index: Int)], from pos: Position) -> Warrior? {
            let neighbors = self.neighbors(around: pos).map { self.index(for: $0) }
            return targets.filter({ neighbors.contains($0.index) }).min(by: {
                if $0.warrior.health == $1.warrior.health {
                    return $0.index < $1.index
                }
                return $0.warrior.health < $1.warrior.health
            })?.warrior
        }
        
        func firstMoveToClosest(_ targets: Set<Int>, from initial: Position) -> Int? {
            
            if targets.isEmpty {
                return nil
            }
            
            var seen = Set<Int>()
            let index = self.index(for: initial)
            var toVisit: [Int: (Int, Int?)] = [index: (0, nil)]
            var data = [Int: (distance: Int, firstMove: Int)]()
            while let (index, element) = toVisit.popFirst() {
                let neighbors = openedNeighbors(around: position(at: index))
                for pos in neighbors {
                    let newIndex = self.index(for: pos)
                    if data[newIndex] == nil || data[newIndex]!.distance > element.0 + 1 {
                        data.updateValue((element.0 + 1, element.1 ?? newIndex), forKey: newIndex)
                    }
                    else if data[newIndex]!.distance == element.0 + 1 && data[newIndex]!.firstMove > (element.1 ?? newIndex) {
                        data[newIndex]!.firstMove = element.1 ?? newIndex
                    }
                    if seen.contains(newIndex) || toVisit.contains(where: { $0.key == newIndex }) {
                        continue
                    }
                    if !toVisit.contains(where: { $0.key == newIndex }) {
                        toVisit.updateValue((element.0 + 1, element.1 ?? newIndex), forKey: newIndex)
                    }
                }
                seen.insert(index)
            }
            
            let paths = data.filter({ return targets.contains($0.key) }).sorted(by: {
                if $0.value.distance == $1.value.distance {
                    return $0.key < $1.key
                }
                return $0.value.distance < $1.value.distance
            })
            return paths.first?.value.firstMove
        }
        
        func performFight() -> Int {
            var roundsElapsed = 0
            while true {
                print(self)
                if performRound() {
                    print(self)
                    break
                } else {
                    roundsElapsed += 1
                }
            }
            return roundsElapsed
        }
        
        func performRound() -> Bool {
            
            defer {
                // Remove the deaths
                warriors.removeAll(where: { $0.warrior.health <= 0 })
            }
            
            for (i, element) in warriors.enumerated().sorted(by: { $0.element.index < $1.element.index }) {
                let (warrior, index) = element
                if warrior.health <= 0 {
                    continue
                }
                
                let targets = warriors.filter({ $0.warrior.type != warrior.type && $0.warrior.health > 0 })
                if targets.isEmpty {
                    // We stop immediatly the round. The fight is over
                    return true
                }
                
                // If we're already in range of a target, we hit!
                let pos = self.position(at: index)
                if let target = firstTargetToAttack(targets: targets, from: pos) {
                    warrior.attack(other: target)
                    continue
                }
                
                // Get the places where we would be in range of someone
                let placesToGo = targets.reduce(into: Set<Int>(), { result, value in
                    let pos = self.position(at: value.index)
                    for neighbor in self.openedNeighbors(around: pos) {
                        result.insert(self.index(for: neighbor))
                    }
                })
                
                if placesToGo.isEmpty {
                    continue
                }
                
                // Find the closest place to go
                if let index = firstMoveToClosest(placesToGo, from: pos) {
                    warriors[i].index = index
                    
                    if let target = firstTargetToAttack(targets: targets, from: self.position(at: index)) {
                        warrior.attack(other: target)
                        continue
                    }
                }
            }
            
            // Not finished yet!
            return false
        }
        
        var description: String {
            var string = ""
            for y in 0..<height {
                var warriorsString = ""
                for x in 0..<width {
                    let index = self.index(for: (x: x, y: y))
                    if let warrior = warriors.first(where: { $0.index == index })?.warrior {
                        string += warrior.type == .elf ? "E" : "G"
                        warriorsString += " " + (warrior.type == .elf ? "E" : "G") + "(\(warrior.health))"
                    } else {
                        string += squares[index] == .open ? "." : "#"
                    }
                }
                string += warriorsString
                string += "\n"
            }
            return string
        }
        
        static func parse(from input: String) -> Cavern {
            let lines = input.components(separatedBy: .newlines)
            let height = lines.count, width = lines.first!.count
            
            var squares = [Square](repeating: .wall, count: width * height)
            var warriors = [(warrior: Warrior, index: Int)]()
            for (y,line) in lines.enumerated() {
                for (x,c) in line.enumerated() {
                    let index = Cavern.index(for: (x: x, y: y), in: width)
                    switch c {
                    case "#":
                        squares[index] = .wall
                    case ".":
                        squares[index] = .open
                    case "E":
                        warriors.append((warrior: Warrior(type: .elf), index: index))
                        squares[index] = .open
                    case "G":
                        warriors.append((warrior: Warrior(type: .goblin), index: index))
                        squares[index] = .open
                    default:
                        break
                    }
                }
            }
            
            return Cavern(width: width, height: height, squares: squares, warriors: warriors)
        }
    }
    
    static func run(input: String) {
        let cavern = Cavern.parse(from: input)
        let rounds = cavern.performFight()
        let healthRemaining = cavern.warriors.reduce(0, { $0 + $1.warrior.health })
        print("Solved in \(rounds) rounds")
        print("Result for Day 15-1 is \(rounds * healthRemaining)")
    }
}

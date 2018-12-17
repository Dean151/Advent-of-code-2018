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
        
        let id: Int
        let type: Type
        var attack = 3
        var health = 200
        
        init(id: Int, type: Type) {
            self.id = id
            self.type = type
        }
        
        var hashValue: Int {
            return id
        }
        
        func attack(other: Warrior) {
            other.health -= self.attack
        }
        
        static func == (lhs: Warrior, rhs: Warrior) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    class Cavern {
        enum Square {
            case wall, open
        }
        
        let width: Int
        let height: Int
        
        let squares: [Square]
        var initialWarriors: [(warrior: Warrior, index: Int)]
        
        init(width: Int, height: Int, squares: [Square], warriors: [(warrior: Warrior, index: Int)]) {
            self.width = width
            self.height = height
            self.squares = squares
            self.initialWarriors = warriors
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
        
        func openedNeighbors(around pos: Position, warriors: [(warrior: Warrior, index: Int)]) -> [Position] {
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
        
        func firstMoveToClosest(_ targets: Set<Int>, from initial: Position, warriors: [(warrior: Warrior, index: Int)]) -> Int? {
            if targets.isEmpty {
                return nil
            }
            
            var toVisit = [Int: (distance: Int, firstMove: Int)]()
            var visited = [Int: (distance: Int, firstMove: Int)]()
            for move in openedNeighbors(around: initial, warriors: warriors) {
                let index = self.index(for: move)
                toVisit[index] = (distance: 1, firstMove: index)
            }
            
            var currentDistance = 1
            while let (index, move) = toVisit.sorted(by: {
                if $0.value.distance == $1.value.distance {
                    return $0.key < $1.key
                }
                return $0.value.distance < $1.value.distance
            }).first {
                if move.distance > currentDistance && !targets.intersection(visited.keys).isEmpty {
                    // Check if we have a target matching
                    // If so, we have completed the stuff
                    break
                }
                
                currentDistance = move.distance
                for newMove in openedNeighbors(around: self.position(at: index), warriors: warriors) {
                    let newIndex = self.index(for: newMove)
                    if toVisit[newIndex] == nil && visited[newIndex] == nil {
                        toVisit[newIndex] = (distance: move.distance + 1, firstMove: move.firstMove)
                    }
                }
                visited[index] = (distance: move.distance + 1, firstMove: move.firstMove)
                toVisit.removeValue(forKey: index)
            }
            
            let reachedTargets = targets.intersection(visited.keys)
            if !reachedTargets.intersection(visited.keys).isEmpty {
                let target = visited[reachedTargets.min()!]!
                return target.firstMove
            }
            
            return nil
        }
        
        func performFight(elfesAttack: Int = 3) -> (outcome: Int, elfesWonWithNoLoss: Bool) {
            var warriors = initialWarriors
            
            // Initialize warriors
            warriors.forEach({ (warrior, _) in
                warrior.health = 200
                warrior.attack = warrior.type == .elf ? elfesAttack : 3
            })
            
            var roundsElapsed = 0
            while true {
                if performRound(warriors: &warriors) {
                    break
                } else {
                    roundsElapsed += 1
                }
            }
            let outcome = roundsElapsed * warriors.reduce(0, { $0 + $1.warrior.health })
            let elfesWon = warriors.first!.warrior.type == .elf
            return (outcome, elfesWon && warriors.count == initialWarriors.filter({ $0.warrior.type == .elf }).count)
        }
        
        func performRound(warriors: inout [(warrior: Warrior, index: Int)]) -> Bool {
            
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
                    for neighbor in self.openedNeighbors(around: pos, warriors: warriors) {
                        result.insert(self.index(for: neighbor))
                    }
                })
                
                if placesToGo.isEmpty {
                    continue
                }
                
                // Find the closest place to go
                if let index = firstMoveToClosest(placesToGo, from: pos, warriors: warriors) {
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
        
        static func parse(from input: String) -> Cavern {
            let lines = input.components(separatedBy: .newlines).filter({ !$0.isEmpty })
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
                        warriors.append((warrior: Warrior(id: index, type: .elf), index: index))
                        squares[index] = .open
                    case "G":
                        warriors.append((warrior: Warrior(id: index, type: .goblin), index: index))
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
        let results = cavern.performFight()
        print("Battle outcome for Day 15-1 is \(results.outcome)")
        
        var attack = 4
        while true {
            let results = cavern.performFight(elfesAttack: attack)
            if results.elfesWonWithNoLoss {
                print("Winning elves battle outcome for Day 15-2 is \(results.outcome)")
                break
            }
            attack += 1
        }
    }
}

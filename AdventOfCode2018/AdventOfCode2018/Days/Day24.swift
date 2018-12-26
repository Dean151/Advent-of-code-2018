//
//  Day24.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 24/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day24: Day {
    
    class Group: Equatable, Hashable {
        enum Team: String {
            case immuneSystem, infection
        }
        
        enum AttackType: String {
            case bludgeoning, cold, fire, radiation, slashing
        }
        
        typealias Attack = (type: AttackType, damage: Int)
        
        let id: Int
        let team: Team
        let initiative: Int
        let attack: Attack
        let immunities: Set<AttackType>
        let weaknesses: Set<AttackType>
        let hitPoints: Int
        var numberOfUnits: Int
        
        init(id: Int, team: Team, initiative: Int, attack: Attack, immunities: Set<AttackType>, weaknesses: Set<AttackType>, hitPoints: Int, initialNumberOfUnits: Int) {
            self.id = id
            self.team = team
            self.initiative = initiative
            self.attack = attack
            self.immunities = immunities
            self.weaknesses = weaknesses
            self.hitPoints = hitPoints
            self.numberOfUnits = initialNumberOfUnits
        }
        
        func attackDammage(boost: Int) -> Int {
            return attack.damage + (team == .immuneSystem ? boost : 0)
        }
        
        func effectivePower(boost: Int) -> Int {
            return numberOfUnits * attackDammage(boost: boost)
        }
        
        func potentialDamage(madeBy attacker: Group, boost: Int) -> Int {
            if immunities.contains(attacker.attack.type) {
                return 0
            }
            return (weaknesses.contains(attacker.attack.type) ? 2 : 1) * attacker.effectivePower(boost: boost)
        }
        
        func attack(defender: Group, boost: Int) {
            let damage = defender.potentialDamage(madeBy: self, boost: boost)
            defender.numberOfUnits -= min(defender.numberOfUnits, damage / defender.hitPoints)
        }
        
        var hashValue: Int {
            return id.hashValue
        }
        
        static func == (lhs: Group, rhs: Group) -> Bool {
            return lhs.id == rhs.id && lhs.team == rhs.team
        }
        
        static let regex = try! NSRegularExpression(pattern: "^(\\d+) units each with (\\d+) hit points (?:\\((.+)\\)\\ )?with an attack that does (\\d+) ([a-z]+) damage at initiative (\\d+)$", options: .caseInsensitive)
        
        static func from(id: Int, line: String, team: Team) -> Group? {
            let matches = Group.regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))
            guard let match = matches.first else {
                return nil
            }
            let nbUnits = Int(match.group(at: 1, in: line))!
            let hitPoints = Int(match.group(at: 2, in: line))!
            let attackValue = Int(match.group(at: 4, in: line))!
            let attackType = AttackType(rawValue: match.group(at: 5, in: line))!
            let initiative = Int(match.group(at: 6, in: line))!
            
            var immunities = Set<AttackType>()
            var weaknesses = Set<AttackType>()
            for types in match.group(at: 3, in: line).components(separatedBy: "; ") {
                if types.hasPrefix("immune to ") {
                    types.dropFirst("immune to ".count).components(separatedBy: ", ").compactMap({ AttackType(rawValue: $0) }).forEach({
                        immunities.insert($0)
                    })
                }
                if types.hasPrefix("weak to ") {
                    types.dropFirst("weak to ".count).components(separatedBy: ", ").compactMap({ AttackType(rawValue: $0) }).forEach({
                        weaknesses.insert($0)
                    })
                }
            }
            
            return Group(id: id, team: team, initiative: initiative, attack: (type: attackType, damage: attackValue), immunities: immunities, weaknesses: weaknesses, hitPoints: hitPoints, initialNumberOfUnits: nbUnits)
        }
    }
    
    static func parseUnits(input: String) -> [Group] {
        var id = 1
        var groups = [Group]()
        var team = Group.Team.immuneSystem
        for line in input.components(separatedBy: .newlines) where !line.isEmpty {
            if line == "Immune System:" {
                id = 1
                team = .immuneSystem
                continue
            }
            if line == "Infection:" {
                id = 1
                team = .infection
                continue
            }
            guard let group = Group.from(id: id, line: line, team: team) else {
                continue
            }
            groups.append(group)
            id += 1
        }
        return groups
    }
    
    static func fight(units: [Group], boost: Int = 0) -> (winner: Group.Team, leftUnits: [Group]) {
        // Let make stuff mutable
        var units = units
        
        mainLoop: while true {
            
            // Target Selection Phase
            var targets = [Group: Group?]()
            var targetted = Set<Group>()
            for attacker in units.sorted(by: {
                if $0.effectivePower(boost: boost) == $1.effectivePower(boost: boost) {
                    return $0.initiative > $1.initiative
                }
                return $0.effectivePower(boost: boost) > $1.effectivePower(boost: boost)
            }) {
                let potentialTargets = units.filter({ $0.team != attacker.team })
                if potentialTargets.isEmpty {
                    break mainLoop
                }
                // Find the one with the most damage
                if let target = potentialTargets.filter({ !targetted.contains($0) }).max(by: {
                    if $0.potentialDamage(madeBy: attacker, boost: boost) == $1.potentialDamage(madeBy: attacker, boost: boost) {
                        return $0.effectivePower(boost: boost) < $1.effectivePower(boost: boost)
                    }
                    return $0.potentialDamage(madeBy: attacker, boost: boost) < $1.potentialDamage(madeBy: attacker, boost: boost)
                }) {
                    targets.updateValue(target, forKey: attacker)
                    targetted.insert(target)
                }
            }
            
            // Attacking Phase
            for (attacker, target) in targets.sorted(by: { $0.key.initiative > $1.key.initiative }) {
                guard let target = target, attacker.numberOfUnits > 0 && target.numberOfUnits > 0 else {
                    continue
                }
                attacker.attack(defender: target, boost: boost)
            }
            
            // Removing dead units
            units = units.filter({ $0.numberOfUnits > 0 })
        }
        units = units.filter({ $0.numberOfUnits > 0 })
        
        return (winner: units.first!.team, leftUnits: units)
    }
    
    static func run(input: String) {
        let units = parseUnits(input: input)
        
        var outcome = fight(units: units)
        print("Number of left units for Day 24-1 is \(outcome.leftUnits.reduce(0, { $0 + $1.numberOfUnits }))")
        
        var boost = 0
        while outcome.winner != .immuneSystem {
            boost += 1
            outcome = fight(units: units, boost: boost)
            print("\(boost) - \(outcome.winner.rawValue) - \(outcome.leftUnits.reduce(0, { $0 + $1.numberOfUnits }))")
        }
        print("Minimum boost to make immune system win for Day 24-2 is \(boost)")
    }
}


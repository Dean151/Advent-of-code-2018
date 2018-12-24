//
//  Day24.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 24/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day24: Day {
    
    class Group {
        enum Team {
            case immuneSystem, infection
        }
        
        enum AttackType: String {
            case bludgeoning, cold, fire, radiation, slashing
        }
        
        typealias Attack = (type: AttackType, damage: Int)
        
        let team: Team
        let initiative: Int
        let attack: Attack
        let immunities: Set<AttackType>
        let weaknesses: Set<AttackType>
        let hitPoints: Int
        var numberOfUnits: Int
        
        init(team: Team, initiative: Int, attack: Attack, immunities: Set<AttackType>, weaknesses: Set<AttackType>, hitPoints: Int, initialNumberOfUnits: Int) {
            self.team = team
            self.initiative = initiative
            self.attack = attack
            self.immunities = immunities
            self.weaknesses = weaknesses
            self.hitPoints = hitPoints
            self.numberOfUnits = initialNumberOfUnits
        }
        
        static let regex = try! NSRegularExpression(pattern: "^(\\d+) units each with (\\d+) hit points (?:\\((.+)\\)\\ )?with an attack that does (\\d+) ([a-z]+) damage at initiative (\\d+)$", options: .caseInsensitive)
        
        static func from(line: String, team: Team) -> Group? {
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
            
            return Group(team: team, initiative: initiative, attack: (type: attackType, damage: attackValue), immunities: immunities, weaknesses: weaknesses, hitPoints: hitPoints, initialNumberOfUnits: nbUnits)
        }
    }
    
    static func parseUnits(input: String) -> [Group] {
        var groups = [Group]()
        var team = Group.Team.immuneSystem
        for line in input.components(separatedBy: .newlines) where !line.isEmpty {
            if line == "Immune System:" {
                team = .immuneSystem
                continue
            }
            if line == "Infection:" {
                team = .infection
                continue
            }
            guard let group = Group.from(line: line, team: team) else {
                continue
            }
            groups.append(group)
        }
        return groups
    }
    
    static func run(input: String) {
        let units = parseUnits(input: input)
        print(units.count)
    }
}

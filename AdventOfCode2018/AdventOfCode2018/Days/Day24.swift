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
        
        static func from(line: String, team: Team) -> Group? {
            // REGEX!
            // ^(\d+) units each with (\d+) hit points (?:\((.+)\)\ )?with an attack that does (\d+) ([a-z]+) damage at initiative (\d+)$
            
            // TODO: parse !
            print(line)
            print(team)
            return nil
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
        print(units)
    }
}

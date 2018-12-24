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
        typealias Attack = (type: AttackType, damage: Int)
        
        enum Team {
            case immuneSystem
            case infection
        }
        
        enum AttackType: String {
            case bludgeoning, cold, fire, radiation, slashing
        }
        
        let id: Int
        let team: Team
        let initiative: Int
        let attack: Attack
        let hitPoints: Int
        var numberOfUnits: Int
        
        init(id: Int, team: Team, initiative: Int, attack: Attack, hitPoints: Int, initialNumberOfUnits: Int) {
            self.id = id
            self.team = team
            self.initiative = initiative
            self.attack = attack
            self.hitPoints = hitPoints
            self.numberOfUnits = initialNumberOfUnits
        }
    }
    
    static func run(input: String) {
        
    }
}

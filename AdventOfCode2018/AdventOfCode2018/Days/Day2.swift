//
//  Day2.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 04/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day2: Day {
    
    struct Box {
        let id: String
        let occurances: Set<Int>
        
        init(id: String) {
            self.id = id
            
            var occurances = [Character: Int]()
            for letter in id {
                if let old = occurances[letter] {
                    occurances[letter] = old + 1
                } else {
                    occurances[letter] = 1
                }
            }
            self.occurances = Set(occurances.values)
        }
        
        func hasLetter(repeating number: Int) -> Bool {
            return occurances.contains(number)
        }
        
        func distance(from box: Box) -> UInt {
            guard box.id.count == self.id.count else {
                return UInt.max
            }
            
            var distance: UInt = 0
            for (index, char) in self.id.enumerated() {
                let stringIndex = box.id.index(box.id.startIndex, offsetBy: index)
                if box.id[stringIndex] != char {
                    distance += 1
                }
            }
            return distance
        }
    }
    
    static func run() {
        let input = try! Input.get("day2.txt")
        let boxesIds = input.components(separatedBy: .newlines)
        
        var boxes2 = 0
        var boxes3 = 0
        
        // We sort boxesIds to make it easier to find the one that are identical for Day 2-2
        let boxes = boxesIds.sorted().map({ Box(id: $0) })
        
        for box in boxes {
            if box.hasLetter(repeating: 2) {
                boxes2 += 1
            }
            if box.hasLetter(repeating: 3) {
                boxes3 += 1
            }
        }
        
        print("Checksum of boxes for Day 2-1 is \(boxes2 * boxes3)")
        
        var idA = ""
        var idB = ""
        for index in 0..<boxes.count-2 {
            let boxA = boxes[index]
            let boxB = boxes[index+1]
            if boxA.distance(from: boxB) == 1 {
                idA = boxA.id
                idB = boxB.id
                break
            }
        }
        
        if (idA.isEmpty || idB.isEmpty) {
            // Sorted was not the good option : this mean that the first letter is the one that is different... Too bad
            print("No similar ids found")
        } else {
            print("Similar ids found: \(idA) & \(idB)")
            
            // Let drop the correct character
            for (index, char) in idA.enumerated() {
                let stringIndex = idB.index(idB.startIndex, offsetBy: index)
                if idB[stringIndex] != char {
                    idB.remove(at: stringIndex)
                    break
                }
            }
            
            print("Similar letter of similar ids boxes for Day 2-2 are \(idB)")
        }
    }
}

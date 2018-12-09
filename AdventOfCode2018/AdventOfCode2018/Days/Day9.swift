//
//  Day9.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 09/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day9: Day {
    
    static func run(input: String) {
        let components = input.components(separatedBy: .whitespaces)
        guard components.count == 8, let playersCount = Int(components[0]), let lastMarbleValue = Int(components[6]) else {
            fatalError("Unrecognized puzzle input!")
        }
        
        var currentPlayer = 1
        var currentIndex = 0
        var circle = [0]
        var scores = [Int: Int](minimumCapacity: playersCount)
        
        for marble in 1...lastMarbleValue {
            if marble % 23 == 0 {
                // Weird rule happens
                currentIndex = (currentIndex + circle.count - 7) % circle.count
                let removed = circle.remove(at: currentIndex)
                
                // Update the score
                let current = scores[currentPlayer] ?? 0
                scores.updateValue(current + marble + removed, forKey: currentPlayer)
            } else {
                // Just insert the stuff :)
                currentIndex = (currentIndex + 2) % circle.count
                
                if currentIndex == 0 {
                    currentIndex = circle.count
                    circle.append(marble)
                } else {
                    circle.insert(marble, at: currentIndex)
                }
            }
            
            // Change the current player ;)
            currentPlayer = (currentPlayer + 1) % playersCount
            if currentPlayer == 0 {
                currentPlayer = playersCount
            }
        }
        
        let scoreMax = scores.max(by: { $0.value < $1.value })!
        print("Player \(scoreMax.key) won with \(scoreMax.value) for Day 9-1")
    }
}

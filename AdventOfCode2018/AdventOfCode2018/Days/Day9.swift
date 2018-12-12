//
//  Day9.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 09/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day9: Day {
    
    struct Circle {
        
        var current = 0
        var marbles: [Int: (prev: Int, next: Int)]
        
        init(minimumCapacity capacity: Int) {
            self.marbles = [Int: (prev: Int, next: Int)](minimumCapacity: capacity)
        }
        
        var count: Int {
            return marbles.count
        }
        
        mutating func rotate(_ i: Int) {
            if marbles.isEmpty || i == 0 {
                return
            }
            
            for _ in 1...abs(i) {
                current = marbles[current].flatMap({ i < 0 ? $0.prev : $0.next })!
            }
        }
        
        mutating func insert(_ value: Int) {
            if let next = marbles[current]?.next {
                marbles[current]?.next = value
                marbles[value] = (prev: current, next: next)
                marbles[next]?.prev = value
            } else {
                // It's the first
                marbles[value] = (prev: value, next: value)
            }
            current = value
        }
        
        mutating func remove() -> Int {
            let (prev, next) = marbles[current]!
            marbles[prev]?.next = next
            marbles[next]?.prev = prev
            
            let value = current
            current = next
            return value
        }
        
    }
    
    static func run(input: String) {
        let components = input.components(separatedBy: .whitespaces)
        guard components.count == 8, let playersCount = Int(components[0]), let lastMarbleValue = Int(components[6]) else {
            fatalError("Unrecognized puzzle input!")
        }
        
        // For day 9-2
        let realLastMarbleValue = lastMarbleValue * 100
        
        var currentPlayer = 1
        var circle = Circle(minimumCapacity: realLastMarbleValue)
        var scores = [Int: Int](minimumCapacity: playersCount)
        
        circle.insert(0)
        
        for marble in 1...realLastMarbleValue {
            if marble % 23 == 0 {
                // Weird rule happens
                circle.rotate(-7)
                let removed = circle.remove()
                
                // Update the score
                let current = scores[currentPlayer] ?? 0
                scores.updateValue(current + marble + removed, forKey: currentPlayer)
            } else {
                // Just insert the stuff :)
                circle.rotate(1)
                circle.insert(marble)
            }
            
            if marble == lastMarbleValue {
                let scoreMax = scores.max(by: { $0.value < $1.value })!
                print("Player \(scoreMax.key) won with \(scoreMax.value) for Day 9-1")
            }
            
            // Change the current player ;)
            currentPlayer = (currentPlayer + 1) % playersCount
            if currentPlayer == 0 {
                currentPlayer = playersCount
            }
        }
        
        let scoreMax = scores.max(by: { $0.value < $1.value })!
        print("Player \(scoreMax.key) won with \(scoreMax.value) for Day 9-2")
    }
}

//
//  Day9.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 09/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day9: Day {
    
    class Marble {
        let value: Int
        
        var previous: Int
        var next: Int
        
        init(value: Int, previous: Int? = nil, next: Int? = nil) {
            self.value = value
            self.previous = previous ?? value
            self.next = next ?? value
        }
    }
    
    struct Circle {
        
        var currentMarbleIndex = 0
        var marbles: [Int: Marble]
        
        init(minimumCapacity capacity: Int) {
            self.marbles = [Int:Marble](minimumCapacity: capacity)
        }
        
        var count: Int {
            return marbles.count
        }
        
        var current: Marble? {
            return marbles[currentMarbleIndex]
        }
        
        mutating func rotate(_ i: Int) {
            if i == 0 || count == 0 {
                return
            }
            
            if i > 0 {
                currentMarbleIndex = current!.next
                rotate(i - 1)
            } else if i < 0 {
                currentMarbleIndex = current!.previous
                rotate(i + 1)
            }
        }
        
        mutating func insert(_ value: Int) {
            
            let marble: Marble
            if let current = current, let next = marbles[current.next] {
                current.next = value
                next.previous = value
                marble = Marble(value: value, previous: current.value, next: next.value)
            } else {
                marble = Marble(value: value)
            }
            
            marbles.updateValue(marble, forKey: value)
            currentMarbleIndex = value
        }
        
        mutating func remove() -> Int {
            guard let current = current, let next = marbles[current.next], let previous = marbles[current.previous] else {
                fatalError("Nothing to remove!")
            }
            
            next.previous = previous.value
            previous.next = next.value
            currentMarbleIndex = next.value
            
            marbles.removeValue(forKey: current.value)
            return current.value
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

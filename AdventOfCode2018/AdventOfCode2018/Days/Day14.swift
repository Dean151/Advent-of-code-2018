//
//  Day14.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 14/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day14: Day {
    
    enum Digit: Int {
        case zero = 0, one, two, three, four, five, six, seven, height, nine
        
        var description: Character {
            switch self {
            case .zero:
                return "0"
            case .one:
                return "1"
            case .two:
                return "2"
            case .three:
                return "3"
            case .four:
                return "4"
            case .five:
                return "5"
            case .six:
                return "6"
            case .seven:
                return "7"
            case .height:
                return "8"
            case .nine:
                return "9"
            }
        }
        
        static func from(char: Character) -> Digit? {
            switch char {
            case "0":
                return .zero
            case "1":
                return .one
            case "2":
                return .two
            case "3":
                return .three
            case "4":
                return .four
            case "5":
                return .five
            case "6":
                return .six
            case "7":
                return .seven
            case "8":
                return .height
            case "9":
                return .nine
            default:
                return nil
            }
        }
        
        static func from(string: String) -> [Digit] {
            return string.reduce(into: [Digit](), { (result, c) in
                Digit.from(char: c).flatMap({ result.append($0) })
            })
        }
        
        static func + (lhs: Digit, rhs: Digit) -> [Digit] {
            switch lhs.rawValue + rhs.rawValue {
            case 0:
                return [.zero]
            case 1:
                return [.one]
            case 2:
                return [.two]
            case 3:
                return [.three]
            case 4:
                return [.four]
            case 5:
                return [.five]
            case 6:
                return [.six]
            case 7:
                return [.seven]
            case 8:
                return [.height]
            case 9:
                return [.nine]
            case 10:
                return [.one, .zero]
            case 11:
                return [.one, .one]
            case 12:
                return [.one, .two]
            case 13:
                return [.one, .three]
            case 14:
                return [.one, .four]
            case 15:
                return [.one, .five]
            case 16:
                return [.one, .six]
            case 17:
                return [.one, .seven]
            case 18:
                return [.one, .height]
            default:
                fatalError("Impossible case occurred")
            }
        }
    }
    
    static func run(input: String) {
        let input = input.components(separatedBy: .newlines).first!
        let numberOfRecipies = Int(input)!
        let toFind = Digit.from(string: input)
        
        var recipies = [Digit.three, Digit.seven]
        var currentA = 0
        var currentB = 1
        
        var part1done = false
        var part2done = false
        var found = 0
        
        while !part1done || !part2done {
            let a = recipies[currentA]
            let b = recipies[currentB]
            
            let c = a + b
            recipies.append(contentsOf: c)
            
            if !part1done && recipies.count >= numberOfRecipies + 10 {
                let result = recipies[numberOfRecipies...(numberOfRecipies+9)].reduce("", { return $0 + "\($1.description)" })
                print("Score of next ten recipies for Day 14-1 are \(result)")
                part1done = true
            }
            
            if !part2done {
                for (i,digit) in c.enumerated() {
                    if digit == toFind[found] {
                        found += 1
                    } else if digit == toFind[0] {
                        found = 1
                    } else {
                        found = 0
                        continue
                    }
                    if found == toFind.count {
                        print("Input found after making \(recipies.count - toFind.count - c.count + i + 1) recipies for Day 14-2")
                        part2done = true
                        break
                    }
                }
            }
            
            currentA = (currentA + 1 + a.rawValue) % recipies.count
            currentB = (currentB + 1 + b.rawValue) % recipies.count
        }
    }
}

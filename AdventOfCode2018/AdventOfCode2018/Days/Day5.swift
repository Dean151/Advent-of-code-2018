//
//  Day5.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 05/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day5 {
    
    static func run() {
        let input = try! Input.get("day5.txt")
        var string = input.components(separatedBy: .newlines).first!
        
        var i = string.startIndex
        while (i < string.index(before: string.endIndex)) {
            let a = Int(string[i].unicodeScalars.first!.value)
            let b = Int(string[string.index(after: i)].unicodeScalars.first!.value)
            
            if abs(a - b) == 32 {
                // Capitals and simple are separated from 32 unicode numbers exactly
                // We remove the elements, and we keep going
                string.remove(at: string.index(after: i))
                string.remove(at: i)
                // We move backward (if possible)
                if i != string.startIndex {
                    i = string.index(before: i)
                }
            } else {
                // We move forward
                i = string.index(after: i)
            }
        }
        
        print("Left over of the polymer for Day 5-1 is \(string.count)")
    }
}

//
//  Day.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 05/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation
import QuartzCore

protocol Day {
    static func run()
}

extension Day {
    static func solve() {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumFractionDigits = 3
        
        print("Solving \(Self.self)")
        
        let start = CACurrentMediaTime()
        run()
        let end = CACurrentMediaTime()
        
        let elapsed = end - start
        print("Solved \(Self.self) in \(formatter.string(from: NSNumber(value: elapsed))!)s")
        
        print("—————————————————————————————————")
    }
}

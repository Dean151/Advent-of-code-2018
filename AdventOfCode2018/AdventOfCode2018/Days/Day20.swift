//
//  Day20.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 20/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day20: Day {
    
    static func fartestPath(for regex: String) -> String {
        var regex = regex.trimmingCharacters(in: CharacterSet(charactersIn: "^$"))
        while let end = regex.firstIndex(of: ")") {
            // Find the corresponding opening (
            guard let start = regex[...end].lastIndex(of: "(") else {
                fatalError("Closing ) does not have it's (")
            }
            let subregex = regex[regex.index(after: start)...regex.index(before: end)]
            regex.replaceSubrange((start...end).relative(to: regex), with: fartestPath(for: String(subregex)))
        }
        let fartest = regex.components(separatedBy: "|").max(by: { $0.count < $1.count })!
        print(fartest)
        return fartest
    }
    
    static func run(input: String) {
        let regex = input.components(separatedBy: .newlines).first!
        
        assert(fartestPath(for: "^WNE$").count == 3)
        assert(fartestPath(for: "^ENWWW(NEEE|SSE(EE|N))$").count == 10)
        assert(fartestPath(for: "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$").count == 18)
        assert(fartestPath(for: "^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$").count == 23)
        assert(fartestPath(for: "^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$").count == 31)
        
        print("Max number of doors we can pass threw for Day 20-1 is \(fartestPath(for: regex).count)")
    }
}

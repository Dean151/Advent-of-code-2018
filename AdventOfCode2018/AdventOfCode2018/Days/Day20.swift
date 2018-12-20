//
//  Day20.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 20/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day20: Day {
    
    static func furtestPath(for regex: String) -> String {
        var regex = regex
        var path = ""
        while regex.count > 0 {
            let c = regex.removeLast()
            if c == "^" {
                break
            } else if c == "$" {
                continue
            } else if c == "(" {
                // Get the substring and pass it threw furtestPath
                guard let i = regex.lastIndex(of: "(") else {
                    fatalError("Oups, ( parsing error")
                }
                let subregex = regex[i...].dropFirst()
                regex.removeLast(subregex.count + 1)
            } else if c == "(" {
                // Should not occurs if precedent block works as intended
                fatalError("Oups, ( parsing error")
            } else {
                path.append(c)
            }
        }
        return String(path.reversed())
    }
    
    static func run(input: String) {
        let regex = input.components(separatedBy: .newlines).first!
        
        assert(furtestPath(for: "^WNE$").count == 3)
        assert(furtestPath(for: "^ENWWW(NEEE|SSE(EE|N))$").count == 10)
        assert(furtestPath(for: "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$").count == 18)
        assert(furtestPath(for: "^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$").count == 23)
        assert(furtestPath(for: "^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$").count == 31)
        
        print("Max number of doors we can pass threw for Day 20-1 is \(furtestPath(for: regex).count)")
    }
}

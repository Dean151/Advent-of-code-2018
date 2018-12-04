//
//  input.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 04/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Input {
    
    static let homeURL = FileManager.default.homeDirectoryForCurrentUser
    static let inputURL = homeURL.appendingPathComponent("Developer/Autres/Advent-of-code-2018/AdventOfCode2018/AdventOfCode2018/Input/")
    
    static func get(_ file: String) throws -> String {
        let inputData = try Data(contentsOf: inputURL.appendingPathComponent(file))
        guard let input = String(data: inputData, encoding: .utf8) else {
            throw NSError() as Error
        }
        return input
    }
}

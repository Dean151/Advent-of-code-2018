//
//  Day10.swift
//  AdventOfCode2018
//
//  Created by Thomas DURAND on 10/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day10: Day {
    
    struct Vector: Equatable {
        
        var x, y: Int
        
        func distance(from: Vector) -> Int {
            return abs(x - from.y) + abs(y - from.y)
        }
        
        static func == (lhs: Vector, rhs: Vector) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
        
        static func + (lhs: Vector, rhs: Vector) -> Vector {
            return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
        }
        
        static func * (lhs: Int, rhs: Vector) -> Vector {
            return Vector(x: lhs * rhs.x, y: lhs * rhs.y)
        }
    }
    
    struct Point {
        let position: Vector
        let velocity: Vector
        
        static let regex = try! NSRegularExpression(pattern: "^position=< ?(-?\\d+),  ?(-?\\d+)> velocity=< ?(-?\\d+),  ?(-?\\d+)>$", options: .caseInsensitive)
        static func from(string: String) -> Point? {
            let matches = Point.regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            guard let match = matches.first else {
                return nil
            }
            
            let x = Int(match.group(at: 2, in: string))!
            let y = Int(match.group(at: 1, in: string))!
            let vx = Int(match.group(at: 4, in: string))!
            let vy = Int(match.group(at: 3, in: string))!
            
            let position = Vector(x: x, y: y)
            let velocity = Vector(x: vx, y: vy)
            return Point(position: position, velocity: velocity)
        }
        
        func position(after time: Int) -> Vector {
            return position + time * velocity
        }
        
        func point(after time: Int) -> Point {
            return Point(position: position(after: time), velocity: velocity)
        }
    }
    
    class Grid: CustomStringConvertible {
        let initialPoints: [Point]
        
        var time = 0
        init(initialPoints points: [Point]) {
            self.initialPoints = points
        }
        
        var points: [Point] {
            return initialPoints.map {
                return $0.point(after: time)
            }
        }
        
        var size: (width: Int, height: Int) {
            let points = self.points
            let xs = points.map { $0.position.x }
            let ys = points.map { $0.position.y }
            
            return (width: xs.max()! - xs.min()!, height: ys.max()! - ys.min()!)
        }
        
        func run(duration: Int = 1) {
            time += duration
        }
        
        var description: String {
            // Find min/max of x/y
            let points = self.points
            let xs = points.map { $0.position.x }
            let ys = points.map { $0.position.y }
            
            var string = "\n"
            for x in xs.min()!...xs.max()! {
                for y in ys.min()!...ys.max()! {
                    string += !points.filter({ $0.position == Vector(x: x, y: y) }).isEmpty ? "#" : "."
                }
                string += "\n"
            }
            
            return string
        }
    }
    
    static func run(input: String) {
        let points = input.components(separatedBy: .newlines).compactMap({ return Point.from(string: $0) })
        
        let grid = Grid(initialPoints: points)
        var size = grid.size
        while true {
            grid.run()
            let newSize = grid.size
            if (newSize.height > size.height) {
                // It's diverging !
                // rollback once
                grid.time -= 1
                break
            }
            size = newSize
        }
        print("Now it looks like that for Day 10-1:")
        print(grid)
        print("Points took \(grid.time)s to converge for Day 10-2")
    }
}

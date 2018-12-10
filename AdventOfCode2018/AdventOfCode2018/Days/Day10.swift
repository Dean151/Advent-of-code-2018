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
    
    class Point {
        var position: Vector
        let velocity: Vector
        
        init(position: Vector, velocity: Vector) {
            self.position = position
            self.velocity = velocity
        }
        
        static let regex = try! NSRegularExpression(pattern: "^position=< ?(-?\\d+),  ?(-?\\d+)> velocity=< ?(-?\\d+),  ?(-?\\d+)>$", options: .caseInsensitive)
        static func from(string: String) -> Point? {
            let matches = Point.regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            guard let match = matches.first else {
                return nil
            }
            
            let x = Int(match.group(at: 1, in: string))!
            let y = Int(match.group(at: 2, in: string))!
            let vx = Int(match.group(at: 3, in: string))!
            let vy = Int(match.group(at: 4, in: string))!
            
            let position = Vector(x: x, y: y)
            let velocity = Vector(x: vx, y: vy)
            return Point(position: position, velocity: velocity)
        }
        
        func run(duration: Int = 1) {
            self.position = self.position(after: duration)
        }
        
        func position(after time: Int) -> Vector {
            return position + time * velocity
        }
    }
    
    class Grid: CustomStringConvertible {
        
        var points: [Point]
        var time = 0
        
        init(initialPoints points: [Point]) {
            self.points = points
        }
        
        var minMax: (minX: Int, minY: Int, maxX: Int, maxY: Int) {
            var minX = Int.max
            var maxX = 0
            var minY = Int.max
            var maxY = 0
            for point in points {
                minX = min(minX, point.position.x)
                maxX = max(maxX, point.position.x)
                minY = min(minY, point.position.y)
                maxY = max(maxY, point.position.y)
            }
            return (minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        }
        
        var size: (width: Int, height: Int) {
            let (minX, minY, maxX, maxY) = minMax
            return (width: maxX - minX, height: maxY - minY)
        }
        
        func run(duration: Int = 1) {
            time += duration
            points.forEach { $0.run(duration: duration) }
        }
        
        var description: String {
            // Find min/max of x/y
            let (minX, minY, maxX, maxY) = minMax
            
            var string = "\n"
            for y in minY...maxY {
                for x in minX...maxX {
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
                grid.run(duration: -1)
                break
            }
            size = newSize
        }
        print("Now it looks like that for Day 10-1:")
        print(grid)
        print("Points took \(grid.time)s to converge for Day 10-2")
    }
}

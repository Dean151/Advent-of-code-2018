//
//  Day6.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 06/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day6: Day {
    
    struct Point: Hashable {
        
        static var xMin = Int.max
        static var xMax = Int.min
        static var yMin = Int.max
        static var yMax = Int.min
        
        static var center: Point {
            return Point(id: nil, x: (xMax-xMin)/2, y: (yMax-yMin)/2)
        }
        
        let id: Int?
        let x, y: Int
        
        static func from(id: Int?, string: String) -> Point? {
            let components = string.components(separatedBy: .punctuationCharacters)
            guard components.count == 2 else {
                return nil
            }
            
            let cleanedLast = components.last!.components(separatedBy: .whitespaces).last!
            guard let x = Int(components.first!), let y = Int(cleanedLast) else {
                return nil
            }
            
            updateMinAndMax(x: x, y: y)
            return Point(id: id, x: x, y: y)
        }
        
        static func updateMinAndMax(x: Int, y: Int) {
            xMin = min(x, xMin)
            xMax = max(x, xMax)
            yMin = min(y, yMin)
            yMax = max(y, yMax)
        }
        
        func distance(from point: Point) -> Int {
            return abs(x - point.x) + abs(y - point.y)
        }
    }
    
    class Grid {
        
        let offset: Point
        let width: Int
        let height: Int
        
        var infinite: [Int] = []
        
        init(width: Int, height: Int, offset: Point) {
            self.offset = offset
            self.width = width
            self.height = height
        }
        
        func index(x: Int, y: Int) -> Int {
            return (y - offset.y) * width + (x - offset.x)
        }
        
        func coords(at index: Int) -> (x: Int, y: Int) {
            let x = index % width + offset.x
            let y = ((index - (index % width)) / width) + offset.y
            return (x: x, y: y)
        }
        
        func isBorder(at index: Int) -> Bool {
            let coords = self.coords(at: index)
            return coords.x == offset.x || coords.y == offset.y || coords.x == width+offset.x-1 || coords.y == height+offset.y-1
        }
        
        func point(at index: Int) -> Point {
            let coords = self.coords(at: index)
            return Point(id: nil, x: coords.x, y: coords.y)
        }
        
        func largestNonInfiniteRegion(for points: [Point]) -> Int {
            
            var infinitePoints = Set<Int>()
            var sums = [Int: Int](minimumCapacity: points.count)
            
            for index in 0..<width*height {
                guard let influent = self.influent(at: index, with: points) else {
                    continue
                }
                
                if isBorder(at: index) {
                    infinitePoints.insert(influent)
                    sums.removeValue(forKey: influent)
                    continue
                }
                
                if infinitePoints.contains(influent) {
                    continue
                }
                
                if let value = sums[influent] {
                    sums.updateValue(value + 1, forKey: influent)
                } else {
                    sums.updateValue(1, forKey: influent)
                }
            }
            
            return sums.max(by: { $0.value < $1.value })!.value
        }
        
        func influent(at index: Int, with points: [Point]) -> Int? {
            var min = Int.max
            var influent: Int?
            
            for point in points {
                let distance = point.distance(from: self.point(at: index))
                if distance < min {
                    min = distance
                    influent = point.id!
                } else if distance == min {
                    influent = nil
                }
            }
            
            return influent
        }
    }
    
    static func run() {
        let input = try! Input.get("day6.txt")
        let points = input.components(separatedBy: .newlines)
            .enumerated()
            .compactMap { Point.from(id: $0.offset, string: $0.element) }
        
        let grid = Grid(width: (Point.xMax - Point.xMin + 1), height: (Point.yMax - Point.xMin + 1), offset: Point(id: nil, x: Point.xMin, y: Point.yMin))
        
        let size = grid.largestNonInfiniteRegion(for: points)
        print("Largest non infinite area for Day 6-1 is \(size)")
    }
}

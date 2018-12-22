//
//  File.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 22/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day22: Day {
    
    typealias Position = (x: Int, y: Int)
    
    enum Tool {
        case none, torch, climbingGear
    }
    
    struct Node: Hashable {
        let index: Int
        let tool: Tool
    }
    
    struct Cave {
        enum Region: Int, CustomStringConvertible {
            case rocky = 0, wet, narrow
            
            var description: String {
                switch self {
                case .rocky:
                    return "."
                case .wet:
                    return "="
                case .narrow:
                    return "|"
                }
            }
            
            var validTools: Set<Tool> {
                switch self {
                case .rocky:
                    return Set<Tool>([.torch, .climbingGear])
                case .wet:
                    return Set<Tool>([.none, .climbingGear])
                case .narrow:
                    return Set<Tool>([.none, .torch])
                }
            }
        }
        
        let width: Int
        let height: Int
        let target: Node
        let regions: [Int: Region]
        
        static func index(at pos: Position, width: Int) -> Int {
            return pos.y * width + pos.x
        }
        
        func index(at pos: Position) -> Int {
            return Cave.index(at: pos, width: width)
        }
        
        init(target: Position, depth: Int) {
            let width = target.x * 5
            let height = target.y + 50
            
            let capacity = width * height
            var erosions = [Int: Int](minimumCapacity: capacity)
            var regions = [Int: Region](minimumCapacity: capacity)
            
            for y in 0..<height {
                for x in 0..<width {
                    let index = Cave.index(at: (x: x, y: y), width: width)
                    let geoIndex: Int
                    if (x == 0 && y == 0) || (x == target.x && y == target.y) {
                        geoIndex = 0
                    } else if y == 0 {
                        geoIndex = 16807 * x
                    } else if x == 0 {
                        geoIndex = 48271 * y
                    } else {
                        geoIndex = erosions[index - width]! * erosions[index - 1]!
                    }
                    let erosion = (geoIndex + depth) % 20183
                    erosions[index] = erosion
                    regions[index] = Region(rawValue: erosion % 3)!
                }
            }
            
            self.width = width
            self.height = height
            self.target = Node(index: Cave.index(at: target, width: width), tool: .torch)
            self.regions = regions
        }
        
        var riskLevel: Int {
            let pos = position(at: target.index)
            return regions.filter({
                let p = position(at: $0.key)
                return p.x <= pos.x && p.y <= pos.y
            }).map({ $0.value.rawValue }).reduce(0, +)
        }
        
        func neighbors(from node: Node) -> [(node: Node, upcost: Int)] {
            
            let pos = position(at: node.index)
            if pos.x == width - 1 {
                fatalError("Edge is too close...")
            }
            if pos.y == height - 1 {
                fatalError("We need to go deeper...")
            }
            
            let indexes = [
                (x: pos.x, y: pos.y - 1),
                (x: pos.x - 1, y: pos.y),
                (x: pos.x + 1, y: pos.y),
                (x: pos.x, y: pos.y + 1),
            ].filter({ $0.x >= 0 && $0.y >= 0 }).map({ index(at: $0) })
            
            var neighbors = [(node: Node, upcost: Int)]()
            
            // We can change our tool
            for newTool in regions[node.index]!.validTools where newTool != node.tool {
                neighbors.append((node: Node(index: node.index, tool: newTool), upcost: 7))
            }
            
            // We can move to regions where our tool is valid
            for newIndex in indexes where regions[newIndex]!.validTools.contains(node.tool) {
                neighbors.append((node: Node(index: newIndex, tool: node.tool), upcost: 1))
            }
            return neighbors
        }
        
        func position(at index: Int) -> Position {
            let x = index % width, y = (index - x) / width
            return (x: x, y: y)
        }
        
        func distanceFromTarget(to node: Node) -> Int {
            let a = position(at: node.index)
            let b = position(at: target.index)
            let distance = abs(b.x - a.x) + abs(b.y - a.y)
            return distance
        }
        
        var minimumReachTime: Int {
            
            // A* algorithm :)
            var toVisit = [Node: (cost: Int, heuristic: Int)]()
            var visited = [Node: Int]()
            
            // Adding the starting block
            let start = Node(index: 0, tool: .torch)
            toVisit[start] = (cost: 0, heuristic: 0)
            
            while let (node, (cost, _)) = toVisit.min(by: { $0.value.heuristic < $1.value.heuristic }) {
                toVisit.removeValue(forKey: node)
                
                if (node == target) {
                    print("Found path with cost : \(cost)")
                    return cost
                }
                
                for (newNode, upcost) in neighbors(from: node) {
                    let newCost = cost + upcost
                    if let alreadyVisited = visited[newNode], alreadyVisited < newCost {
                        continue
                    }
                    if let inVisitList = toVisit[newNode], inVisitList.cost < newCost {
                        continue
                    }
                    toVisit[newNode] = (cost: newCost, heuristic: newCost + distanceFromTarget(to: newNode))
                }
                
                visited[node] = cost
            }
            
            fatalError("Target not reachable")
        }
        
        func printRegion() {
            var string = ""
            for y in 0..<height {
                for x in 0..<width {
                    let index = self.index(at: (x: x, y: y))
                    string += regions[index]!.description
                }
                string += "\n"
            }
            print(string)
        }
        
        func printCost(_ visited: [Node: Int]) {
            var string = ""
            for y in 0..<height {
                for x in 0..<width {
                    let index = self.index(at: (x: x, y: y))
                    if let point = visited.filter({ $0.key.index == index }).min(by: { $0.value < $1.value }) {
                        string += "\(point.value)\t"
                    } else {
                        string += "-\t"
                    }
                }
                string += "\n"
            }
            print(string)
        }
    }
    
    static func run(input: String) {
        // Extract stuff from the input
        let components = input.components(separatedBy: .newlines).compactMap({ !$0.isEmpty ? $0.components(separatedBy: .whitespaces).last : nil })
        let depth = Int(components.first!)!
        let coords = components.last!.components(separatedBy: ",").compactMap({ Int($0) })
        let target = (x: coords.first!, y: coords.last!)
        
        // Create the cavern
        let cavern = Cave(target: target, depth: depth)
        
        assert(Cave(target: (x: 10, y: 10), depth: 510).riskLevel == 114)
        print("Risk level of the cavern for Day 21-1 is \(cavern.riskLevel)")
        
        assert(Cave(target: (x: 10, y: 10), depth: 510).minimumReachTime == 45)
        print("Minimum time to reach the target for Day 21-2 is \(cavern.minimumReachTime)")
    }
}

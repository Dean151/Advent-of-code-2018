//
//  Day8.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 08/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day8: Day {
    
    struct Node {
        
        let children: [Node]
        let metadata: [Int]
        
        var metadataSum: Int {
            return metadata.reduce(0, +)
        }
        
        var recursiveMetadataSum: Int {
            return children.map({ $0.recursiveMetadataSum }).reduce(metadataSum, +)
        }
        
        var value: Int {
            if children.isEmpty {
                return metadataSum
            }
            
            return metadata.reduce(0, { carry, metadata in
                if metadata < 1 || metadata > children.count {
                    return carry
                }
                return carry + children[metadata - 1].value
            })
        }
        
        static func from(numbers: [Int]) -> (node: Node, leftOver: [Int]) {
            var numbers = numbers
            
            let childrenNumber = numbers.removeFirst()
            let metadataNumber = numbers.removeFirst()
            
            var children: [Node] = []
            for _ in 0..<childrenNumber {
                let (child, left) = from(numbers: numbers)
                children.append(child)
                numbers = left
            }
            
            let metadata = [Int](numbers.prefix(metadataNumber))
            numbers.removeFirst(metadataNumber)
            
            let node = Node(children: children, metadata: metadata)
            return (node: node, leftOver: numbers)
        }
    }
    
    static func run(input: String) {
        let numbers = input.components(separatedBy: .whitespacesAndNewlines).compactMap({ return Int($0) })
        
        let (node, left) = Node.from(numbers: numbers)
        assert(left.isEmpty)
        
        print("Sum of all metadata for Day 8-1 is \(node.recursiveMetadataSum)")
        
        print("Global value for Day 8-2 is \(node.value)")
    }
}

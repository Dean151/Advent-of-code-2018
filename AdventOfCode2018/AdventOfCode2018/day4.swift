//
//  day4.swift
//  AdventOfCode2018
//
//  Created by Thomas Durand on 04/12/2018.
//  Copyright © 2018 Thomas Durand. All rights reserved.
//

import Foundation

class Day4 {
    
    typealias Date = (month: Int, day: Int, hour: Int, minute: Int)
    
    enum EventType {
        case beginShift(guardId: Int)
        case fallAsleep
        case wakesUp
        
        static func from(string: String, id: Int?) -> EventType? {
            switch string {
            case "begins shift":
                guard let id = id else {
                    return nil
                }
                return .beginShift(guardId: id)
            case "falls asleep":
                return .fallAsleep
            case "wakes up":
                return .wakesUp
            default:
                return nil
            }
        }
    }
    
    struct Event {
        let date: Date
        let type: EventType
        
        static let regex = try! NSRegularExpression(pattern: "^\\[1518-(\\d+)-(\\d+) (\\d+):(\\d+)\\] (?:Guard #(\\d+) )?(begins shift|falls asleep|wakes up)$", options: .caseInsensitive)
        
        static func from(string: String) -> Event? {
            let matches = Event.regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            
            guard let match = matches.first else {
                return nil
            }
            
            let month = Int(match.group(at: 1, in: string))!
            let day = Int(match.group(at: 2, in: string))!
            let hour = Int(match.group(at: 3, in: string))!
            let minute = Int(match.group(at: 4, in: string))!
            let date: Date = (month: month, day: day, hour: hour, minute: minute)
            
            guard let type = EventType.from(string: match.group(at: 6, in: string), id: Int(match.group(at: 5, in: string))) else {
                return nil
            }
            
            return Event(date: date, type: type)
        }
    }
    
    struct Guard {
        let id: Int
        
        init(id: Int) {
            self.id = id
        }
        
        var totalAsleep = 0
        var minutesAsleep = [Int: Int]()
        
        // Tracking
        var falledAsleep: Date?
        
        mutating func fallsAsleep(date: Date) {
            guard falledAsleep == nil else {
                fatalError("Guard \(id) falls asleep but is already sleeping!")
            }
            falledAsleep = date
        }
        
        mutating func wakesUp(date: Date) {
            guard let oldDate = self.falledAsleep else {
                fatalError("Guard \(id) awake but is not asleep!")
            }
            falledAsleep = nil
            
            // Perform calculation of time spent sleeping
            // Hours is always 0 when sleeping ; it'll be easy
            totalAsleep += date.minute - oldDate.minute + 1
            for minute in oldDate.minute...date.minute {
                if let oldCumul = minutesAsleep[minute] {
                    minutesAsleep[minute] = oldCumul + 1
                } else {
                    minutesAsleep[minute] = 1
                }
            }
        }
    }
    
    static func run() {
        let homePath = FileManager.default.homeDirectoryForCurrentUser
        let inputPath = "Developer/Autres/Advent-of-code-2018/AdventOfCode2018/AdventOfCode2018/day4.txt"
        let inputUrl = homePath.appendingPathComponent(inputPath)
        let inputData = try! Data(contentsOf: inputUrl)
        let input = String(data: inputData, encoding: .utf8)!
        
        let events = input.components(separatedBy: .newlines)
            .compactMap({ return Event.from(string: $0) })
            .sorted(by: {
                $0.date < $1.date
            })
        
        var guards = [Int: Guard]()
        var currentGuard: Int?
        for event in events {
            switch event.type {
            case .beginShift(guardId: let id):
                currentGuard = id
                // Create guard if needed
                if guards[currentGuard!] == nil {
                    guards[currentGuard!] = Guard(id: currentGuard!)
                }
            case .fallAsleep:
                guards[currentGuard!]!.fallsAsleep(date: event.date)
            case .wakesUp:
                guards[currentGuard!]!.wakesUp(date: event.date)
            }
        }
        
        // Get the guard that sleep the most
        let mostSleepingGuard = guards.sorted { $0.value.totalAsleep > $1.value.totalAsleep }.first!.value
        print("The most sleepy guard was asleep for \(mostSleepingGuard.totalAsleep) minutes!")
        // Get his most sleeped minute
        let mostSleepedMinute = mostSleepingGuard.minutesAsleep.sorted { $0.value > $1.value }.first!.key
        print("His most sleeped minute is \(mostSleepedMinute)")
        print("Multiplication for Day 4-1 is \(mostSleepingGuard.id * mostSleepedMinute)")
    }
}

import Foundation

let inputPath = Bundle.main.url(forResource:"input", withExtension: "txt")
let inputData = try! Data(contentsOf: inputPath!)
let input = String(data: inputData, encoding: .utf8)!
let boxesIds = input.components(separatedBy: .newlines)

struct Box {
    let id: String
    let occurances: Set<Int>
    
    init(id: String) {
        self.id = id
        
        var occurances = [Character: Int]()
        for letter in id {
            if let old = occurances[letter] {
                occurances[letter] = old + 1
            } else {
                occurances[letter] = 1
            }
        }
        self.occurances = Set(occurances.values)
    }
    
    func hasLetter(repeating number: Int) -> Bool {
        return occurances.contains(number)
    }
}

var boxes2 = 0
var boxes3 = 0

for boxId in boxesIds {
    let box = Box(id: boxId)
    if box.hasLetter(repeating: 2) {
        boxes2 += 1
    }
    if box.hasLetter(repeating: 3) {
        boxes3 += 1
    }
}

print("Checksum of boxes for Day 2-1 is \(boxes2 * boxes3)")

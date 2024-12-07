//
//  day5.swift
//  aoc24
//
//  Created by Personal on 12/5/24.
//

import Foundation
import Parsing

struct Day5: Day {
    var day: String = "5"
    
    var testInput: String {
        """
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""
    }

    struct PrintDefinition {
        let orderings: [(Int, Int)]
        let updates: [[Int]]
    }
    
    func parsePrintDefinition(_ input: String) -> PrintDefinition {
        let orderingParser = Parse(input: Substring.self) {
            Int.parser()
            "|"
            Int.parser()
        }.map { ($0, $1) }
        
        let updateParser = Parse(input: Substring.self) {
            Many {
                Int.parser()
            } separator: {
                ","
            }
        }
        
        let inputParser = Parse(input: Substring.self) {
            Many {
                orderingParser
            } separator: {
                Whitespace(1, .vertical)
            }
            Whitespace(2, .vertical)
            Many {
                updateParser
            } separator: {
                Whitespace(1, .vertical) 
            }
        }
        
        let (orderings, updates) = try! inputParser.parse(input)
        return PrintDefinition(orderings: orderings, updates: updates)
    }
    
    func partitionUpdates(_ definition: PrintDefinition) -> ([[Int]], [[Int]]) {
        var validUpdates: [[Int]] = []
        var invalidUpdates: [[Int]] = []
        
        // Check each update array
        for update in definition.updates {
            // Skip empty updates
            if update.isEmpty {
                continue
            }
            // Create index lookup dictionary for this update
            let indices = Dictionary(uniqueKeysWithValues: 
                update.enumerated().map { ($1, $0) }
            )
            
            var isValid = true
            // Check each ordering rule against this update
            for (before, after) in definition.orderings {
                // Get indices from our lookup dictionary
                guard let beforeIndex = indices[before],
                      let afterIndex = indices[after] else {
                    continue // Skip if either number isn't in the update
                }
                
                // If the 'after' number appears before the 'before' number,
                // this update is invalid
                if afterIndex < beforeIndex {
                    isValid = false
                    break // No need to check other rules once we know it's invalid
                }
            }
            
            if isValid {
                validUpdates.append(update)
            } else {
                invalidUpdates.append(update)
            }
        }
        
        return (validUpdates, invalidUpdates)
    }
    
    func checkUpdates(_ updates: [[Int]]) -> Int {
        return updates.reduce(0) { sum, update in
            let middleIndex = update.count / 2
            return sum + update[middleIndex]
        }
    }
    
    func part1(input: String) {
        let definition = parsePrintDefinition(input)
        let (validUpdates, _) = partitionUpdates(definition)
        let result = checkUpdates(validUpdates)
        print("Part 1: \(result)")
    }
    
    func testPart1(input: String) {
        let definition = parsePrintDefinition(input)
        let (validUpdates, _) = partitionUpdates(definition)
        let result = checkUpdates(validUpdates)
        assert(result == 143, "Expected 143 but got \(result)")
    }

    func fixUpdates(_ orderings: [(Int, Int)], _ invalidUpdates: [[Int]]) -> Int {
        var sum = 0
        
        for update in invalidUpdates {
            // Create sorted version using custom comparator
            let sortedUpdate = update.sorted { a, b in
                orderings.contains(where: { $0.0 == a && $0.1 == b })
            }
            
            // Add middle value to sum
            let middleIndex = sortedUpdate.count / 2
            sum += sortedUpdate[middleIndex]
        }
        
        return sum
    }
    
    func part2(input: String) {
        let definition = parsePrintDefinition(input)
        let (_, invalidUpdates) = partitionUpdates(definition)
        let result = fixUpdates(definition.orderings, invalidUpdates)
        print("Part 2: \(result)")
    }
    
    func testPart2(input: String) {
        let definition = parsePrintDefinition(input)
        let (_, invalidUpdates) = partitionUpdates(definition)
        let result = fixUpdates(definition.orderings, invalidUpdates)
        assert(result == 123, "Expected 123 but got \(result)")
    }
}

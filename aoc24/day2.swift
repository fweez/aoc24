//
//  day2.swift
//  aoc24
//
//  Created by Personal on 12/2/24.
//

import Foundation
import Parsing


// create a function called part1 which takes a multiline input string of space separated numbers, parses them using the Parsing library 
// into an array of arrays of ints. for each array of ints, print the list of ints then if the numbers in order are all increasing or 
// decreasing and the maximum difference between adjacent numbers is 3 print "safe"; otherwise print "unsafe".
func part1(_ input: String) -> Int {
    let lines = input.split(separator: "\n")
    let numberArrays = lines.map { line in
        line.split(separator: " ").compactMap { Int($0) }
    }
    
    var safeCount = 0
    for numbers in numberArrays {
        // Check if array has at least 2 numbers
        guard numbers.count >= 2 else {
            continue
        }
        
        // Check if increasing
        var isIncreasing = true
        var isDecreasing = true
        
        for i in 0..<(numbers.count-1) {
            if numbers[i+1] <= numbers[i] {
                isIncreasing = false
            }
            if numbers[i+1] >= numbers[i] {
                isDecreasing = false
            }
        }
        // Check max difference is 3 or less
        let maxDiff = zip(numbers.dropFirst(), numbers).map { abs($0 - $1) }.max() ?? 0

        if (isIncreasing || isDecreasing) && maxDiff <= 3 {
            safeCount += 1
        }
    }
    
    return safeCount
}

func testPart1() {
    let testInput = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""
    
    let result = part1(testInput)
    assert(result == 2, "Expected 2 but got \(result)")
}

func part2(_ input: String) -> Int {
    let lines = input.split(separator: "\n")
    let numberArrays = lines.map { line in
        line.split(separator: " ").compactMap { Int($0) }
    }
    
    var safeCount = 0
    for numbers in numberArrays {
        // Check if array has at least 2 numbers
        guard numbers.count >= 2 else {
            continue
        }
        
        // First check if sequence is valid without removing anything
        var isIncreasing = true
        var isDecreasing = true
        var maxDiff = 0
        
        for i in 0..<(numbers.count-1) {
            if numbers[i+1] <= numbers[i] {
                isIncreasing = false
            }
            if numbers[i+1] >= numbers[i] {
                isDecreasing = false
            }
            maxDiff = max(maxDiff, abs(numbers[i+1] - numbers[i]))
        }
        
        if (isIncreasing || isDecreasing) && maxDiff <= 3 {
            safeCount += 1
            continue
        }
        
        // If not valid, try removing each number
        for skipIndex in 0..<numbers.count {
            let reducedNumbers = numbers.enumerated().filter { $0.offset != skipIndex }.map { $0.element }
            
            // Reset flags for this attempt
            isIncreasing = true
            isDecreasing = true
            maxDiff = 0
            
            for i in 0..<(reducedNumbers.count-1) {
                if reducedNumbers[i+1] <= reducedNumbers[i] {
                    isIncreasing = false
                }
                if reducedNumbers[i+1] >= reducedNumbers[i] {
                    isDecreasing = false
                }
                maxDiff = max(maxDiff, abs(reducedNumbers[i+1] - reducedNumbers[i]))
            }
            
            if (isIncreasing || isDecreasing) && maxDiff <= 3 {
                safeCount += 1
                break  // Found a valid solution, no need to check other removals
            }
        }
    }
    
    return safeCount
}


func testPart2() {
    let testInput = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""
    
    let result = part2(testInput)
    assert(result == 4, "Expected 4 but got \(result)")
}


func day2() {
    print("Testing part 1")
    testPart1()
    print("Part 1")
    let input = readFile("day2.txt")
    print(part1(input))
    print("Testing part 2")
    testPart2()
    print("Part 2")
    print(part2(input))
}

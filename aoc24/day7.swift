//
//  day7.swift
//  aoc24
//
//  Created by Personal on 12/7/24.
//

import Foundation
import Parsing

struct Day7: Day {
    var day: String = "7"
    
    var testInput: String {
        """
        190: 10 19
        3267: 81 40 27
        83: 17 5
        156: 15 6
        7290: 6 8 6 15
        161011: 16 10 13
        192: 17 8 14
        21037: 9 7 18 13
        292: 11 6 16 20
        """
    }

    func parseEquation(_ input: String) -> [(target: Int, numbers: [Int])] {
        return input.split(separator: "\n").map { line in
            let parts = line.split(separator: ":")
            let target = Int(parts[0])!
            let numbers = parts[1].split(separator: " ")
                .compactMap { Int($0) }
            return (target: target, numbers: numbers)
        }
    }

    func canEqualWithSolutionGeneration(target: Int, numbers: [Int], generateSolutions: (Int, Int) -> [Int]) -> Bool {
        // Use dynamic programming to store intermediate results
        // Key is (index, currentValue), value is whether target can be reached
        struct MemoKey: Hashable {
            let index: Int
            let currentValue: Int
        }
        
        var memo: [MemoKey: Bool] = [:]
        
        func dp(_ index: Int, _ currentValue: Int) -> Bool {
            // Base case - reached end of numbers
            if index >= numbers.count {
                return currentValue == target
            }
            
            // Check memo
            let key = MemoKey(index: index, currentValue: currentValue)
            if let cached = memo[key] {
                return cached
            }
            // First number case
            if index == 0 {
                return dp(1, numbers[0])
            }
            
            // Generate solutions with current number
            let solutions = generateSolutions(currentValue, numbers[index])
            
            // Try each solution
            let result = solutions.contains { solution in
                solution <= target && dp(index + 1, solution)
            }
            
            memo[key] = result
            return result
        }
        
        return dp(0, 0)
    }
    
    func canEqual(target: Int, numbers: [Int]) -> Bool {
        return canEqualWithSolutionGeneration(target: target, numbers: numbers) { a, b in
            [a + b, a * b]
        }
    }

    func canEqualWithConcatenation(target: Int, numbers: [Int]) -> Bool {
        return canEqualWithSolutionGeneration(target: target, numbers: numbers) { a, b in
            // Try addition, multiplication, and concatenation
            let concatenated = Int(String(a) + String(b))!
            return [a + b, a * b, concatenated]
        }
    }


    private func solveEquations(input: String, canEqualFn: (Int, [Int]) -> Bool) -> Int {
        let equations = parseEquation(input)
        return equations
            .filter { canEqualFn($0.target, $0.numbers) }
            .map { $0.target }
            .reduce(0, +)
    }

    func part1(input: String) {
        let sum = solveEquations(input: input, canEqualFn: canEqual)
        print("Part 1: \(sum)")
    }
    
    func testPart1(input: String) {
        let sum = solveEquations(input: input, canEqualFn: canEqual)
        assert(sum == 3749, "Expected 3749 but got \(sum)")
    }

    func part2(input: String) {
        let sum = solveEquations(input: input, canEqualFn: canEqualWithConcatenation)
        print("Part 2: \(sum)")
    }
    
    func testPart2(input: String) {
        let sum = solveEquations(input: input, canEqualFn: canEqualWithConcatenation)
        assert(sum == 11387, "Expected 11387 but got \(sum)")
    }
}

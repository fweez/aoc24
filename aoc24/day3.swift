//
//  day3.swift
//  aoc24
//
//  Created by Personal on 12/3/24.
//

import Foundation
import Parsing

struct Day3: Day {
    var day: String = "3"
    
    var testInput: String {
        "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
    }

    func computeMultiplications(_ input: String) -> Int {
        let multiplyParser = Parse(input: Substring.self) {
            "mul("
            Int.parser()
            ","
            Int.parser()
            ")"
        }
        
        let parser = Many {
            OneOf {
                multiplyParser.map { t -> (Int, Int)? in t }
                Prefix(1).map { _ in nil }
            }
        }
        
        let results = try! parser.parse(input)
        return results.compactMap { $0 }.reduce(0) { sum, pair in
            sum + (pair.0 * pair.1)
        }
    }
    
    func part1(input: String) {
        let result = computeMultiplications(input)
        print("Part 1: \(result)")
    }
    
    func testPart1(input: String) {
        let result = computeMultiplications(input)
        assert(result == 161, "Expected 161 but got \(result)")
    }
    
    enum Command {
        case multiply(Int, Int)
        case doCommand
        case dontCommand
    }
    
    func parseCommands(_ input: String) -> Int {
        let multiplyParser = Parse(input: Substring.self) {
            "mul("
            Int.parser()
            ","
            Int.parser()
            ")"
        }.map { Command.multiply($0, $1) }
        
        let doParser = Parse(input: Substring.self) {
            "do()"
        }.map { _ in Command.doCommand }
        
        let dontParser = Parse(input: Substring.self) {
            "don't()"
        }.map { _ in Command.dontCommand }
        
        let parser = Many {
            OneOf {
                multiplyParser.map { cmd -> Command? in cmd }
                doParser.map { cmd -> Command? in cmd }
                dontParser.map { cmd -> Command? in cmd }
                Prefix(1).map { _ in nil }
            }
        }
        
        let results = try! parser.parse(input)
        var total = 0
        var isSumming = true
        
        for command in results.compactMap({ $0 }) {
            switch command {
            case .multiply(let x, let y) where isSumming:
                total += x * y
            case .doCommand:
                isSumming = true
            case .dontCommand:
                isSumming = false
            default:
                break
            }
        }
        
        return total
    }

    func part2(input: String) {
        let result = parseCommands(input)
        print("Part 2: \(result)")
    }

    func testPart2(input: String) {
        let testInput = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
        let result = parseCommands(testInput)
        assert(result == 48, "Expected 48 but got \(result)")
    }
    
}

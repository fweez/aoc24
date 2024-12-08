//
//  main.swift
//  aoc24
//
//  Created by Personal on 12/1/24.
//

import Foundation

protocol Day {
    init()
    func part1(input: String) -> Void
    func part2(input: String) -> Void
    func testPart1(input: String) -> Void
    func testPart2(input: String) -> Void
    static func run() -> Void
    var day: String { get }
    var input: String { get }
    var testInput: String { get }
}

extension Day {
    var input: String {
        fetch()
    }
    
    static func run() {
        let instance = Self()
        print("Day \(instance.day)")
        instance.testPart1(input: instance.testInput)
        
        let part1Start = Date()
        instance.part1(input: instance.input)
        print(String(format: "(%.5fs)", Date().timeIntervalSince(part1Start)))
        
        instance.testPart2(input: instance.testInput)
        
        let part2Start = Date()
        instance.part2(input: instance.input)
        print(String(format: "(%.5fs)", Date().timeIntervalSince(part2Start)))
        
        print("----------------------------------------")
    }

    func fetch() -> String {
        let filename = "day\(day).txt"
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let fileURL = currentDirectoryURL.appendingPathComponent(filename)
        
        do {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            return contents
        } catch {
            print("Error reading file \(filename): \(error)")
            return ""
        }
    }
}

let days: [String: () -> Void] = [
    "1": day1,
    "2": day2,
    "3": Day3.run,
    "4": Day4.run,
    "5": Day5.run,
    "6": Day6.run,
    "7": Day7.run,
    "8": Day8.run
]

if CommandLine.arguments.count < 2 {
    print("Running all days...")
    days.keys.sorted().forEach { day in
        days[day]?()
    }
} else {
    let day = CommandLine.arguments[1]
    if let runner = days[day] {
        print("Running day \(day)...")
        runner()
    } else {
        print("Error: Day \(day) not found")
        print("Available days: \(days.keys.sorted().joined(separator: ", "))")
    }
}

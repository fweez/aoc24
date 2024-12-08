//
//  main.swift
//  aoc24
//
//  Created by Personal on 12/1/24.
//

import Foundation

print("Hello, World!")

protocol Day {
    func part1(input: String) -> Void
    func part2(input: String) -> Void
    func testPart1(input: String) -> Void
    func testPart2(input: String) -> Void
    func run() -> Void
    var day: String { get }
    var input: String { get }
    var testInput: String { get }
}

extension Day {
    var input: String {
        fetch()
    }
    
    func run() {
        print("Day \(day)")
        testPart1(input: testInput)
        
        let part1Start = Date()
        part1(input: input)
        print(String(format: "(%.5fs)", Date().timeIntervalSince(part1Start)))
        
        testPart2(input: testInput)
        
        let part2Start = Date()
        part2(input: input)
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



day1()
day2()
Day3().run()
Day4().run()
Day5().run()
Day6().run()
Day7().run()
Day8().run()

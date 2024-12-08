//
//  day8.swift
//  aoc24
//
//  Created by Personal on 12/8/24.
//

import Foundation

struct Day8: Day {
    var day: String = "8"
    var testInput: String { """
        ............
        ........0...
        .....0......
        .......0....
        ....0.......
        ......A.....
        ............
        ............
        ........A...
        .........A..
        ............
        ............
        """ }

    func parseAntennas(_ input: String) -> [(frequency: Character, position: (x: Int, y: Int))] {
        input.split(separator: "\n").enumerated().flatMap { y, line in
            line.enumerated().compactMap { x, char in
                char == "." ? nil : (frequency: char, position: (x: x, y: y))
            }
        }
    }

    func generateAntinodes(antennas: [(frequency: Character, position: (x: Int, y: Int))], maxPosition: (x: Int, y: Int), withHarmonics: Bool = false) -> [(x: Int, y: Int)] {
        var antinodes: [(x: Int, y: Int)] = []
        let isValid = { (p: (x: Int, y: Int)) -> Bool in
            p.x >= 0 && p.x <= maxPosition.x && p.y >= 0 && p.y <= maxPosition.y
        }

        for i in 0..<antennas.count {
            let a = antennas[i]
            for b in antennas[(i + 1)...] where a.frequency == b.frequency {
                let dx = b.position.x - a.position.x
                let dy = b.position.y - a.position.y
                
                if withHarmonics {
                    var pos = b.position
                    while true {
                        pos = (x: pos.x + dx, y: pos.y + dy)
                        guard isValid(pos) else { break }
                        antinodes.append(pos)
                    }
                    
                    pos = a.position
                    while true {
                        pos = (x: pos.x - dx, y: pos.y - dy)
                        guard isValid(pos) else { break }
                        antinodes.append(pos)
                    }
                    antinodes.append(contentsOf: [a.position, b.position])
                } else {
                    [(x: b.position.x + dx, y: b.position.y + dy),
                     (x: a.position.x - dx, y: a.position.y - dy)]
                        .filter(isValid)
                        .forEach { antinodes.append($0) }
                }
            }
        }
        return antinodes
    }

    private func solve(_ input: String, withHarmonics: Bool = false) -> Int {
        let antennas = parseAntennas(input)
        let lines = input.split(separator: "\n")
        let maxPosition = (x: lines[0].count - 1, y: lines.count - 1)
        let antinodes = generateAntinodes(antennas: antennas, maxPosition: maxPosition, withHarmonics: withHarmonics)
        return antinodes.enumerated()
            .filter { i, node in !antinodes[..<i].contains(where: { $0.x == node.x && $0.y == node.y }) }
            .count
    }

    func p1(_ input: String) -> Int { solve(input) }
    func p2(_ input: String) -> Int { solve(input, withHarmonics: true) }
    
    func part1(input: String) { print("Part 1: \(p1(input))") }
    func part2(input: String) { print("Part 2: \(p2(input))") }
    
    func testPart1(input: String) {
        let count = p1(input)
        assert(count == 14, "Expected 14 antinodes but got \(count)")
    }
    
    func testPart2(input: String) {
        let count = p2(input)
        assert(count == 34, "Expected 34 antinodes but got \(count)")
    }
}

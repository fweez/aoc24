//
//  day4.swift
//  aoc24
//
//  Created by Personal on 12/4/24.
//

import Foundation
import Parsing

struct Day4: Day {
    var day: String = "4"
    
    func findXMAS(_ input: String) -> Int {
        let lines = input.split(separator: "\n").map(String.init)
        let grid = lines.map { Array($0) }
        var count = 0
        
        // Diagonal and cardinal directions: up-right, up-left, down-right, down-left, up, down, left, right
        let directions = [
            (-1, 1), (-1, -1), (1, 1), (1, -1),
            (-1, 0), (1, 0), (0, -1), (0, 1)
        ]
        // Helper function to check if position is within grid bounds
        func isValid(_ row: Int, _ col: Int) -> Bool {
            row >= 0 && row < grid.count && col >= 0 && col < grid[row].count
        }
        
        // Search for pattern starting from each X
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                if grid[row][col] == "X" {
                    // Try each diagonal direction
                    for (dx, dy) in directions {
                        var currentRow = row
                        var currentCol = col
                        
                        // Look for M
                        currentRow += dx
                        currentCol += dy
                        if !isValid(currentRow, currentCol) || grid[currentRow][currentCol] != "M" {
                            continue
                        }
                        
                        // Look for A
                        currentRow += dx
                        currentCol += dy
                        if !isValid(currentRow, currentCol) || grid[currentRow][currentCol] != "A" {
                            continue
                        }
                        
                        // Look for S
                        currentRow += dx
                        currentCol += dy
                        if !isValid(currentRow, currentCol) || grid[currentRow][currentCol] != "S" {
                            continue
                        }
                        
                        // Found complete pattern
                        count += 1
                        // Removed break to count all patterns from this X
                    }
                }
            }
        }
        
        return count
    }
    
    func part1(input: String) {
        let count = findXMAS(input)
        print("Found \(count) XMAS patterns")
    }
    
    var testInput: String {
        """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""
    }
    
    func testPart1(input: String) {
        let result = findXMAS(input)
        assert(result == 18, "Expected 18 XMAS patterns but found \(result)")
    }

    func checkMAS(grid: [[Character]], from: (row: Int, col: Int), direction: (dx: Int, dy: Int)) -> Bool {
        let rows = grid.count
        let cols = grid[0].count
        
        func isValid(_ row: Int, _ col: Int) -> Bool {
            return row >= 0 && row < rows && col >= 0 && col < cols
        }
        
        let prevRow = from.row - direction.dx
        let prevCol = from.col - direction.dy
        if !isValid(prevRow, prevCol) || grid[prevRow][prevCol] != "M" {
            return false
        }
        
        let nextRow = from.row + direction.dx
        let nextCol = from.col + direction.dy
        if !isValid(nextRow, nextCol) || grid[nextRow][nextCol] != "S" {
            return false
        }
        
        return true
    }

    func findXPattern(grid: [[Character]], row: Int, col: Int, using directions: [(Int, Int)]) -> Bool {
        for i in 0..<directions.count {
            let (dx, dy) = directions[i]
            
            if !checkMAS(grid: grid, from: (row, col), direction: (dx, dy)) {
                continue
            }
            
            // Check perpendicular direction (+90 degrees = +1 in array)
            let perpendicularIndex = (i + 1) % directions.count
            let (perpDx, perpDy) = directions[perpendicularIndex]
            
            if !checkMAS(grid: grid, from: (row, col), direction: (perpDx, perpDy)) {
                continue
            }
            
            // Found valid X pattern
            return true
        }
        return false
    }

    func findMASinXPattern(_ input: String) -> Int {
        let grid = input.split(separator: "\n").map { Array(String($0)) }
        let rows = grid.count
        let cols = grid[0].count
        
        // Diagonal directions: NE, SE, SW, NW
        let diagonalDirections = [
            (-1, 1), (1, 1), (1, -1), (-1, -1)
        ]
        var count = 0
        
        // Search for A's
        for row in 0..<rows {
            for col in 0..<cols {
                if grid[row][col] != "A" { continue }
                // Check diagonal directions only
                if findXPattern(grid: grid, row: row, col: col, using: diagonalDirections) {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    func part2(input: String) {
        let result = findMASinXPattern(input)
        assert(result < 2009, "Result \(result) should be less than 2009")
        print("Part 2: \(result)")
    }
    
    func testPart2(input: String) {
        let result = findMASinXPattern(input)
        assert(result == 9, "Expected 9 but got \(result)")
    }
}

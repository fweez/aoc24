//
//  day6.swift
//  aoc24
//
//  Created by Personal on 12/6/24.
//

import Foundation
import Parsing

enum Direction: Equatable {
    case north
    case east
    case south
    case west
    
    var dx: Int {
        switch self {
        case .north: return 0
        case .east: return 1
        case .south: return 0
        case .west: return -1
        }
    }
    
    var dy: Int {
        switch self {
        case .north: return -1
        case .east: return 0
        case .south: return 1
        case .west: return 0
        }
    }

    func turnRight() -> Direction {
        switch self {
        case .north: return .east
        case .east: return .south 
        case .south: return .west
        case .west: return .north
        }
    }
}

struct Day6: Day {
    var day: String = "6"
    
    var testInput: String {
        """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"""
    }
    
    enum Tile: Equatable {
        case floor
        case visited
        case wall
        case `guard`(Direction)
        case obstructionOpportunity
        case visitedObstruction
    }
    struct MapState {
        var map: [[Tile]]
        let guardPosition: (x: Int, y: Int)?
    }
    
    func parseMap(_ input: String) -> MapState {
        var guardPosition: (x: Int, y: Int)?
        
        let map = input.split(separator: "\n").enumerated().map { y, line in
            line.enumerated().map { (x, char) -> Tile in
                switch char {
                case ".": return .floor
                case "#": return .wall
                case "^":
                    assert(guardPosition == nil, "Multiple guards found in map")
                    guardPosition = (x: x, y: y)
                    return .guard(.north)
                case ">":
                    assert(guardPosition == nil, "Multiple guards found in map")
                    guardPosition = (x: x, y: y)
                    return .guard(.east)
                case "v":
                    assert(guardPosition == nil, "Multiple guards found in map")
                    guardPosition = (x: x, y: y)
                    return .guard(.south)
                case "<":
                    assert(guardPosition == nil, "Multiple guards found in map")
                    guardPosition = (x: x, y: y)
                    return .guard(.west)
                default:
                    assertionFailure("Unexpected character in map: \(char)")
                    return .floor // Only reached if assertions are disabled
                }
            }
        }
        
        assert(guardPosition != nil, "Map must contain exactly one guard")
        
        return MapState(map: map, guardPosition: guardPosition)
    }

    func isValid(pos: (x: Int, y: Int), map: [[Tile]]) -> Bool {
        pos.x >= 0 && pos.x < map[0].count && pos.y >= 0 && pos.y < map.count
    }

    func findWallInDirection(from startPos: (x: Int, y: Int), 
                           direction: Direction, 
                           in map: [[Tile]]) -> (x: Int, y: Int)? {
        var scanPos = startPos
        
        // Scan until we hit map boundary
        while isValid(pos: scanPos, map: map) {
            if case .wall = map[scanPos.y][scanPos.x] {
                return scanPos
            }
            scanPos.x += direction.dx
            scanPos.y += direction.dy
        }
        return nil
    }

    func checkForObstructionOpportunities(_ state: MapState, facing newDirection: Direction) -> [[Tile]] {
        guard let guardPos = state.guardPosition else { return state.map }
        var newMap = state.map
        
        // Find second wall by scanning in new direction and third wall after turning right
        if let secondWallPos = findWallInDirection(
            from: (x: guardPos.x + newDirection.dx, 
                  y: guardPos.y + newDirection.dy),
            direction: newDirection,
            in: newMap
        ),
        let thirdWallPos = findWallInDirection(
            from: (x: secondWallPos.x + newDirection.turnRight().dx,
                  y: secondWallPos.y + newDirection.turnRight().dy),
            direction: newDirection.turnRight(),
            in: newMap
        ) {
            // Scan back from third wall until we reach guard's row/column
            var scanPos = thirdWallPos
            while isValid(pos: scanPos, map: newMap) {
                if (newDirection.dx != 0 && scanPos.y == guardPos.y) ||
                   (newDirection.dy != 0 && scanPos.x == guardPos.x) {
                    // Found intersection point, mark one position past it
                    let obstructionPos = (
                        x: scanPos.x + newDirection.turnRight().turnRight().dx,
                        y: scanPos.y + newDirection.turnRight().turnRight().dy
                    )
                    
                    if isValid(pos: obstructionPos, map: newMap),
                       case .floor = newMap[obstructionPos.y][obstructionPos.x] {
                        newMap[obstructionPos.y][obstructionPos.x] = .obstructionOpportunity
                    }
                    break
                }
                scanPos.x -= newDirection.turnRight().dx
                scanPos.y -= newDirection.turnRight().dy
            }
        }
        return newMap
    }

    func advanceMap(_ state: MapState) -> MapState {
        guard let guardPos = state.guardPosition,
              case let .guard(guardDirection) = state.map[guardPos.y][guardPos.x] else {
            return state // No guard or invalid guard position
        }
        
        var newMap = state.map
        var newGuardPos = guardPos
        // Calculate new position
        let newPos = (x: guardPos.x + guardDirection.dx,
                     y: guardPos.y + guardDirection.dy)
        
        // Check if new position is within bounds
        if !isValid(pos: newPos, map: newMap) {
            // Mark current position as visited before guard leaves map
            newMap[guardPos.y][guardPos.x] = .visited
            return MapState(map: newMap, guardPosition: nil)
        }

        // If guard is on an obstruction opportunity, mark it as visited
        if case .obstructionOpportunity = newMap[guardPos.y][guardPos.x] {
            newMap[guardPos.y][guardPos.x] = .visitedObstruction
        }
        
        // Handle valid positions
        switch newMap[newPos.y][newPos.x] {
        case .floor, .visited, .obstructionOpportunity:
            // Mark current position as visited with guard's direction
            newMap[guardPos.y][guardPos.x] = .visited
            // Move guard to new position
            newMap[newPos.y][newPos.x] = .guard(guardDirection)
            newGuardPos = newPos
        case .visitedObstruction:
            // Don't mark as visited if it's already a visited obstruction
            // Move guard to new position
            newMap[newPos.y][newPos.x] = .guard(guardDirection)
            newGuardPos = newPos
        case .wall:
            // Turn 90 degrees and stay in place
            let newDirection = guardDirection.turnRight()
            newMap[guardPos.y][guardPos.x] = .guard(newDirection)
            newGuardPos = guardPos

            // After turning, check for obstruction opportunities
            newMap = checkForObstructionOpportunities(MapState(map: newMap, guardPosition: newGuardPos), facing: newDirection)

        case .guard:
            assertionFailure("Guard cannot move onto another guard position")
            return state
        }
        return MapState(map: newMap, guardPosition: newGuardPos)
    }

    func runPatrol(_ state: MapState) -> MapState {
        var currentState = state
        var iterations = 0
        while currentState.guardPosition != nil {
            currentState = advanceMap(currentState)
            iterations += 1
            assert(iterations < 10_000_000, "Patrol exceeded 10 million iterations - likely infinite loop")
        }
        return currentState
    }

    func countVisited(_ state: MapState) -> Int {
        var count = 0
        for row in state.map {
            for cell in row {
                switch cell {
                case .visited, .visitedObstruction:
                    count += 1
                default:
                    break
                }
            }
        }
        return count
    }
    
    func part1(input: String) {
        let initialState = parseMap(input)
        let finalState = runPatrol(initialState)
        let result = countVisited(finalState)
        print("Part 1: \(result)")
    }
    
    func testPart1(input: String) {
        let initialState = parseMap(input)
        let finalState = runPatrol(initialState)
        let result = countVisited(finalState)
        assert(result == 41, "Expected 41 but got \(result)")
    }

    func visualizeMap(_ state: MapState) -> String {
        var output = ""
        for row in state.map {
            for cell in row {
                let char: Character = {
                    switch cell {
                    case .floor:
                        return "."
                    case .wall:
                        return "#"
                    case .visited:
                        return "x"
                    case .visitedObstruction:
                        return "8"
                    case .guard(let direction):
                        switch direction {
                        case .north:
                            return "^"
                        case .south:
                            return "v"
                        case .west:
                            return "<"
                        case .east:
                            return ">"
                        }
                    case .obstructionOpportunity:
                        return "O"
                    }
                }()
                output.append(char)
            }
            output.append("\n")
        }
        return String(output.dropLast()) // Remove final newline
    }

    func countLoopOpportunities(_ initialState: MapState) -> Int {
        let finalState = runPatrol(initialState)
        var count = 0
        for row in finalState.map {
            for cell in row {
                if case .obstructionOpportunity = cell {
                    count += 1
                }
            }
        }
        return count

    }
    
    func part2(input: String) {
        
    }
    
    func testPart2(input: String) {
        let initialState = parseMap(input)
        let result = countLoopOpportunities(initialState)
        // assert(result == 6, "Expected 6 loop opportunities but got \(result)")
    }
}

//
//  day9.swift
//  aoc24
//
//  Created by Personal on 12/9/24.
//

import Foundation

struct Day9: Day {
    var day: String = "9"
    var testInput: String { "2333133121414131402" }

    enum BlockSection {
        case file(id: Int, length: Int)
        case empty(length: Int)
        
        var description: String {
            switch self {
            case .file(let id, let length): return "F\(id):\(length)"
            case .empty(let length): return "E:\(length)" 
            }
        }
    }


    func parseInput(_ input: String) -> [BlockSection] {
        let numbers = input.compactMap { Int(String($0)) }
        var fileId = 0
        var sections: [BlockSection] = []
        
        for (index, length) in numbers.enumerated() {
            if index % 2 == 0 {
                sections.append(.file(id: fileId, length: length))
                fileId += 1
            } else {
                sections.append(.empty(length: length))
            }
        }
        
        return sections
    }

    func compressBlocks(_ data: [BlockSection]) -> [BlockSection] {
        var mutableData = data
        var emptyIndex = data.indices.first { i in
            if case .empty = data[i] { return true }
            return false
        } ?? 0
        
        var fileIndex = data.indices.reversed().first { i in
            if case .file = data[i] { return true }
            return false
        } ?? (data.count - 1)
        
        while emptyIndex < mutableData.count && fileIndex >= 0 {
            // Bounds check
            if emptyIndex >= mutableData.count || fileIndex >= mutableData.count {
                print("Index out of bounds - emptyIndex: \(emptyIndex), fileIndex: \(fileIndex), array size: \(mutableData.count)")
                break
            }
            
            guard case .empty(let emptyLength) = mutableData[emptyIndex],
                  case .file(let fileId, let fileLength) = mutableData[fileIndex] else {
                print("Pattern match failed - emptyIndex: \(emptyIndex), fileIndex: \(fileIndex)")
                break
            }
            
            let diff = emptyLength - fileLength
            
            if diff < 0 {
                mutableData[emptyIndex] = .file(id: fileId, length: emptyLength)
                mutableData[fileIndex] = .file(id: fileId, length: fileLength - emptyLength)
                emptyIndex += 2
            } else {
                // Bounds check for remove operation
                if fileIndex >= mutableData.count {
                    print("Remove index out of bounds - fileIndex: \(fileIndex), array size: \(mutableData.count)")
                    break
                }
                
                // If fileIndex is below emptyIndex, adjust emptyIndex after removal
                let adjustEmptyIndex = fileIndex < emptyIndex
                mutableData.remove(at: fileIndex)
                if adjustEmptyIndex {
                    emptyIndex -= 1
                }
                
                // Bounds check for insert operation
                if emptyIndex >= mutableData.count {
                    print("Insert index out of bounds - emptyIndex: \(emptyIndex), array size: \(mutableData.count)")
                    break
                }
                mutableData.insert(.file(id: fileId, length: fileLength), at: emptyIndex)
                
                if diff > 0 {
                    // Bounds check for empty block update
                    if emptyIndex + 1 >= mutableData.count {
                        print("Empty block index out of bounds - index: \(emptyIndex + 1), array size: \(mutableData.count)")
                        break
                    }
                    mutableData[emptyIndex + 1] = .empty(length: diff)
                    emptyIndex += 1
                } else {
                    // Bounds check for remove operation
                    if emptyIndex + 1 >= mutableData.count {
                        print("Remove empty block index out of bounds - index: \(emptyIndex + 1), array size: \(mutableData.count)")
                        break
                    }
                    mutableData.remove(at: emptyIndex + 1)
                    emptyIndex += 2
                }
                
                fileIndex = mutableData.indices.reversed().first { i in
                    if case .file = mutableData[i] { return true }
                    return false
                } ?? -1
            }
        }
        return mutableData
    }
    
    func checksum(_ data: [BlockSection]) -> Int {
        var totalSum = 0
        var blockPosition = 0
        
        for block in data {
            if case .file(let fileId, let fileLength) = block {
                // Calculate sum of positions from blockPosition to blockPosition + length
                let positionSum = (blockPosition..<(blockPosition + fileLength)).reduce(0, +)
                totalSum += positionSum * fileId
                blockPosition += fileLength
            } else if case .empty(let emptyLength) = block {
                blockPosition += emptyLength
            }
        }
        
        return totalSum
    }

    func compressFiles(_ data: [BlockSection]) -> [BlockSection] {
        var mutableData = data
        var fileIndex = mutableData.count - 1
        
        // Start from the rightmost file and work backwards
        while fileIndex >= 0 {
            // Skip if not a file block
            guard case .file(let fileId, let fileLength) = mutableData[fileIndex] else {
                fileIndex -= 1
                continue
            }
            
            // Search from start to fileIndex for suitable empty block
            var foundEmptyIndex: Int? = nil
            for i in 0..<fileIndex {
                if case .empty(let emptyLength) = mutableData[i], emptyLength >= fileLength {
                    foundEmptyIndex = i
                    break
                }
            }
            
            // If found suitable empty block, perform the move
            if let emptyIndex = foundEmptyIndex {
                // Get the empty length before removing file
                let emptyLength = { 
                    if case .empty(let len) = mutableData[emptyIndex] { return len }
                    return 0 
                }()
                
                // Replace file with empty space of same length at current position
                mutableData[fileIndex] = .empty(length: fileLength)
                
                // Check for and merge any adjacent empty blocks
                var totalEmptyLength = fileLength
                var startIndex = fileIndex
                var removedBeforeFileIndex = 0
                
                // Check for empty block before
                if fileIndex > 0, case .empty(let leftLength) = mutableData[fileIndex - 1] {
                    totalEmptyLength += leftLength
                    startIndex = fileIndex - 1
                    mutableData.remove(at: fileIndex)
                    removedBeforeFileIndex += 1
                }
                
                // Check for empty block after
                if startIndex < mutableData.count - 1, case .empty(let rightLength) = mutableData[startIndex + 1] {
                    totalEmptyLength += rightLength
                    mutableData.remove(at: startIndex + 1)
                }
                
                // Set the merged empty block
                mutableData[startIndex] = .empty(length: totalEmptyLength)
                
                // Adjust file index based on removed blocks
                fileIndex -= removedBeforeFileIndex
                
                // Insert file before empty space
                mutableData.insert(.file(id: fileId, length: fileLength), at: emptyIndex)
                
                // Update empty block length
                mutableData[emptyIndex + 1] = .empty(length: emptyLength - fileLength)
                
                // If empty block is now zero length, remove it
                if emptyLength - fileLength == 0 {
                    mutableData.remove(at: emptyIndex + 1)
                }
            }
            
            fileIndex -= 1
        }
        
        return mutableData
    }

    
    func solvePart1(_ input: String) -> Int {
        let data = parseInput(input)
        let compressed = compressBlocks(data)
        return checksum(compressed)
    }

    func solvePart2(_ input: String) -> Int {
        let data = parseInput(input)
        let compressed = compressFiles(data)
        let result = checksum(compressed)
        return result
    }

    func part1(input: String) { print("Part 1: \(solvePart1(input))") }
    func part2(input: String) { 
        let result = solvePart2(input)
        assert(result > 6362681593693, "Part 2 result \(result) must be greater than 6362681593693")
        assert(result < 6901433248163, "Part 2 result \(result) must be less than 6901433248163")
        print("Part 2: \(result)")
    }
    
    func testPart1(input: String) {
        let result = solvePart1(input)
        assert(result == 1928, "Expected 1928 for part 1 but got \(result)")
    }
    
    func testPart2(input: String) {
        let result = solvePart2(input)
        assert(result == 2858, "Expected 2858 for part 2 but got \(result)")
    }
} 
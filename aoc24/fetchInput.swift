//
//  fetchInput.swift
//  aoc24
//
//  Created by Personal on 12/1/24.
//

import Foundation

func readFile(_ filename: String) -> String {
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

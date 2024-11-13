//
//  LevelProgress.swift
//  Time Hacker
//
//  Created by Vladimir Milakov on 06.11.2024.
//


import Foundation

struct LevelProgress: Codable {
    var unlockedLevels: Set<Int>
    var lastPlayedLevel: Int
    
    init(unlockedLevels: Set<Int> = [1], lastPlayedLevel: Int = 1) {
        self.unlockedLevels = unlockedLevels
        self.lastPlayedLevel = lastPlayedLevel
    }
    
    mutating func updateLastPlayed(_ level: Int) {
        lastPlayedLevel = level
        save()
    }
    
    static func load() -> LevelProgress {
        if let data = UserDefaults.standard.data(forKey: "levelProgress"),
           let progress = try? JSONDecoder().decode(LevelProgress.self, from: data) {
            return progress
        }
        return LevelProgress(unlockedLevels: [1], lastPlayedLevel: 1)
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "levelProgress")
        }
    }
}

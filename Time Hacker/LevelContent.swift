//
//  LevelContent.swift
//  Time Hacker
//
//  Created by Vladimir Milakov on 06.11.2024.
//


import Foundation

struct LevelContent: Codable {
    let number: Int
    let title: String
    let description: String
    let sceneDescription: String
    let initialMessage: String
    let systemPrompt: String
    let victoryConditions: [String]
    let victoryMessage: String
}
    
   

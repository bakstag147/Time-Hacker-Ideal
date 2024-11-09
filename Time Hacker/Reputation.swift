//
//  Reputation.swift
//  Time Hacker
//
//  Created by Vladimir Milakov on 08.11.2024.
//


import SwiftUI

struct Reputation {
    var score: Int = 50 {
        didSet {
            score = max(0, min(100, score))
        }
    }
    
    var level: ReputationLevel {
        switch score {
        case ..<25: return .hostile
        case 25..<50: return .suspicious
        case 50..<75: return .neutral
        case 75..<90: return .friendly
        default: return .trusting
        }
    }
    
    enum ReputationLevel: String {
        case hostile = "Враждебное"
        case suspicious = "Подозрительное"
        case neutral = "Нейтральное"
        case friendly = "Дружелюбное"
        case trusting = "Доверительное"
        
        var color: Color {
            switch self {
            case .hostile: return .red
            case .suspicious: return .orange
            case .neutral: return .yellow
            case .friendly: return .green
            case .trusting: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .hostile: return "xmark.circle.fill"
            case .suspicious: return "exclamationmark.circle.fill"
            case .neutral: return "minus.circle.fill"
            case .friendly: return "checkmark.circle.fill"
            case .trusting: return "star.circle.fill"
            }
        }
    }
}

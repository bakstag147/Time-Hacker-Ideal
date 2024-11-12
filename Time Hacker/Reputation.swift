import Foundation
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
}

enum ReputationLevel: String {
    case hostile = "REPUTATION_HOSTILE"
    case suspicious = "REPUTATION_SUSPICIOUS"
    case neutral = "REPUTATION_NEUTRAL"
    case friendly = "REPUTATION_FRIENDLY"
    case trusting = "REPUTATION_TRUSTING"
    
    var localizedName: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
    
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

struct ReputationIndicator: View {
    let reputation: Reputation
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: reputation.level.icon)
                .foregroundColor(reputation.level.color)
            
            Text(reputation.level.localizedName) // Используем localizedName вместо rawValue
                .font(.caption)
                .foregroundColor(reputation.level.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(8)
    }
}

//
//  ReputationIndicator.swift
//  Time Hacker
//
//  Created by Vladimir Milakov on 08.11.2024.
//


import SwiftUI

struct ReputationIndicator: View {
    let reputation: Reputation
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: reputation.level.icon)
                .foregroundColor(reputation.level.color)
            
            Text(reputation.level.rawValue)
                .font(.caption)
                .foregroundColor(reputation.level.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(8)
    }
}
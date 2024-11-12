//
//  NetworkErrorView.swift
//  Time Hacker
//
//  Created by Vladimir Milakov on 13.11.2024.
//
import Foundation
import SwiftUI

struct NetworkErrorView: View {
    let errorMessage: String?
    let retryAction: () async -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("NETWORK_ERROR")
                .font(.headline)
            
            Text(errorMessage ?? "UNKNOWN_ERROR")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: {
                Task {
                    await retryAction()
                }
            }) {
                Label("RETRY", systemImage: "arrow.clockwise")
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

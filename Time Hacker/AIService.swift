//
//  AIService.swift
//  Time Hacker
//
//  Created by Vladimir Milakov on 09.11.2024.
//


import Foundation

class AIService {
    private let endpoint = "https://gg40e4wjm2.execute-api.eu-north-1.amazonaws.com/prod/proxy"
    private let maxRetries = 5
    private let initialRetryDelay: UInt64 = 3_000_000_000 // 3 секунды
    
    enum AIError: Error {
        case networkError(Error)
        case apiError(String)
        case invalidResponse
        case overloaded
        case bothProvidersFailed(String)
    }
    
    struct APIResponse: Codable {
        let statusCode: Int
        let headers: [String: String]?
        let body: String
    }
    
    struct MessageResponse: Codable {
        let content: String
        let provider: String?
    }
    
    struct ErrorResponse: Codable {
        let error: String
        let details: String?
        let anthropicError: String?
        let openaiError: String?
    }
    
    func sendMessage(messages: [ChatMessage]) async throws -> String {
        var attempts = 0
        var currentDelay = initialRetryDelay
        
        while attempts < maxRetries {
            do {
                return try await sendMessageAttempt(messages: messages)
            } catch AIError.overloaded {
                attempts += 1
                if attempts < maxRetries {
                    print("API overloaded - retrying \(attempts)/\(maxRetries)...")
                    try await Task.sleep(nanoseconds: currentDelay)
                    currentDelay *= 2
                    continue
                }
                throw AIError.apiError("Service overloaded.")
            }
        }
        
        throw AIError.apiError("Too many trys.")
    }
    
    private func sendMessageAttempt(messages: [ChatMessage]) async throws -> String {
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "messages": messages.map { [
                "role": $0.role == .user ? "user" : "assistant",
                "content": $0.content
            ] },
            "max_tokens": 1024
        ] as [String : Any]
        
        print("\n=== SENT REQUEST ===")
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        print(String(data: jsonData, encoding: .utf8) ?? "")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("\n=== SERVER RESPONSE ===")
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP status code: \(httpResponse.statusCode)")
        }
        print("Answer data: \(String(data: data, encoding: .utf8) ?? "")")
        
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        
        if apiResponse.statusCode == 529 {
            throw AIError.overloaded
        }
        
        guard let bodyData = apiResponse.body.data(using: .utf8) else {
            throw AIError.invalidResponse
        }
        
        if apiResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: bodyData) {
                print("API Error: \(errorResponse)")
                if errorResponse.error == "Both providers failed" {
                    throw AIError.bothProvidersFailed("""
                        Anthropic: \(errorResponse.anthropicError ?? "unknown")
                        OpenAI: \(errorResponse.openaiError ?? "unknown")
                        """)
                }
                throw AIError.apiError(errorResponse.error)
            }
            throw AIError.invalidResponse
        }
        
        guard let messageResponse = try? JSONDecoder().decode(MessageResponse.self, from: bodyData) else {
            throw AIError.invalidResponse
        }
        
        print("Provider: \(messageResponse.provider ?? "unknown")")
        
        return messageResponse.content
            .replacingOccurrences(of: "\\n", with: "\n")
    }
}

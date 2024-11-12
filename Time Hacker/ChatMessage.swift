import Foundation

struct ChatMessage {
    enum Role: String {
        case system
        case user
        case assistant
    }
    
    let role: Role
    let content: String
    let timestamp: Date
    
    init(role: Role, content: String, timestamp: Date = Date()) {
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
    
    // Добавляем статическое свойство для доступа к системному промпту
    static var systemBasePrompt: String {
        get async throws {
            return try await SystemPromptLoader.shared.loadSystemPrompt()
        }
    }
}

// Создаем новый класс для загрузки системного промпта
class SystemPromptLoader {
    static let shared = SystemPromptLoader()
    private let baseURL = "https://gg40e4wjm2.execute-api.eu-north-1.amazonaws.com/prod/getGeneralInstruct"
    private var cachedPrompt: String?
    
    func loadSystemPrompt() async throws -> String {
        // Возвращаем кэшированный промпт, если он есть
        if let cached = cachedPrompt {
            return cached
        }
        
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let prompt = try JSONDecoder().decode(String.self, from: data)
        cachedPrompt = prompt
        return prompt
    }
    
    func clearCache() {
        cachedPrompt = nil
    }
    
}

import SwiftUI

struct ContentView: View {
    @StateObject private var levelManager = LevelManager()
    @State private var showGame = false
    @State private var startLevel = 1
    
    var body: some View {
        ZStack {
            if showGame {
                GameView(
                    startingLevel: startLevel,
                    levelManager: levelManager,
                    showGame: $showGame
                )
            } else {
                MainMenuView(
                    levelManager: levelManager,
                    startGame: {
                        startLevel = 1
                        Task {
                            await levelManager.loadLevel(1)
                            showGame = true
                        }
                    },
                    selectLevel: { selectedLevel in
                        startLevel = selectedLevel
                        Task {
                            await levelManager.loadLevel(selectedLevel)
                            showGame = true
                        }
                    },
                    showGame: $showGame
                )
            }
        }
    }
}

struct LevelTheme {
    let primary: Color // Основной цвет для кнопок и акцентов
    let secondary: Color // Цвет для отправленных сообщений
    let accent: Color // Дополнительный цвет (например, для победных сообщений)
    
    static let themes: [Int: LevelTheme] = [
        1: LevelTheme(
            primary: Color(hex: "0055CC"),    // Darker Blue
            secondary: Color(hex: "3F3D99"),   // Darker Indigo
            accent: Color(hex: "0088CC")       // Darker Light Blue
        ),
        2: LevelTheme(
            primary: Color(hex: "2A8C3A"),    // Darker Green
            secondary: Color(hex: "1F8C3A"),   // Darker Mint
            accent: Color(hex: "208B3A")       // Darker Lime
        ),
        3: LevelTheme(
            primary: Color(hex: "CC1E3F"),    // Darker Pink
            secondary: Color(hex: "CC1F3F"),   // Darker Rose
            accent: Color(hex: "CC3366")       // Darker Hot Pink
        ),
        4: LevelTheme(
            primary: Color(hex: "CC6600"),    // Darker Orange
            secondary: Color(hex: "CC7000"),   // Darker Light Orange
            accent: Color(hex: "CC8033")       // Darker Warm Orange
        ),
        5: LevelTheme(
            primary: Color(hex: "8033AA"),    // Darker Purple
            secondary: Color(hex: "8C3DB3"),   // Darker Light Purple
            accent: Color(hex: "8C5999")       // Darker Soft Purple
        ),
        6: LevelTheme(
            primary: Color(hex: "3F3D99"),    // Darker Indigo
            secondary: Color(hex: "4240A6"),   // Darker Light Indigo
            accent: Color(hex: "4A3DB3")       // Darker Medium Slate Blue
        ),
        7: LevelTheme(
            primary: Color(hex: "CC2E26"),    // Darker Red
            secondary: Color(hex: "CC332D"),   // Darker Light Red
            accent: Color(hex: "CC4040")       // Darker Soft Red
        ),
        8: LevelTheme(
            primary: Color(hex: "008C86"),    // Darker Teal
            secondary: Color(hex: "0099CC"),   // Darker Sky Blue
            accent: Color(hex: "269E99")       // Darker Turquoise
        ),
        9: LevelTheme(
            primary: Color(hex: "CC9900"),    // Darker Golden Yellow
            secondary: Color(hex: "CC9900"),   // Darker Gold
            accent: Color(hex: "CC8800")       // Darker Golden Orange
        ),
        10: LevelTheme(
            primary: Color(hex: "1F7AA6"),    // Darker Electric Blue
            secondary: Color(hex: "007799"),   // Darker Ocean Blue
            accent: Color(hex: "2699B3")       // Darker Sky Blue
        )
    ]
    
    static func forLevel(_ level: Int) -> LevelTheme {
        return themes[level] ?? themes[1]! // Возвращаем тему первого уровня как дефолтную
    }
}

// Расширение для Color чтобы работать с hex-кодами
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct LoadingIndicator: View {
    @State private var animationState = false
    let theme: LevelTheme
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(theme.secondary)
                    .scaleEffect(animationState ? 1.2 : 0.5)
                    .opacity(animationState ? 1 : 0.3)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: animationState
                    )
            }
        }
        .padding()
        .onAppear {
            animationState = true
        }
    }
}

struct MainMenuView: View {
    @ObservedObject var levelManager: LevelManager
    let startGame: () -> Void
    let selectLevel: (Int) -> Void
    @State private var showLevelSelect = false
    @State private var showAboutGame = false
    @Binding var showGame: Bool
    
    // Определяем, является ли устройство маленьким (iPhone SE и подобные)
    private var isSmallDevice: Bool {
        UIScreen.main.bounds.height < 700
    }
    
    var body: some View {
        ZStack {
            Image("bgmenu")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: isSmallDevice ? 20 : 30) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                    .padding(.top, isSmallDevice ? -40 : 0)
                
                VStack(spacing: isSmallDevice ? 12 : 16) {
                    // Показываем кнопку "Продолжить" только если открыто больше одного уровня
                    if levelManager.levelProgress.unlockedLevels.count > 1 {
                        Button(action: {
                            Task {
                                await levelManager.loadLevel(levelManager.levelProgress.lastPlayedLevel)
                                showGame = true
                            }
                        }) {
                            MenuButton(
                                title: String(localized: "CONTINUE_GAME"),
                                systemImage: "arrow.forward.circle.fill"
                            )
                        }
                    }
                    
                    Button(action: startGame) {
                        MenuButton(
                            title: String(localized: "START_GAME"),
                            systemImage: "play.fill"
                        )
                    }
                    
                    Button(action: { showLevelSelect = true }) {
                        MenuButton(
                            title: String(localized: "SELECT_LEVEL"),
                            systemImage: "list.number"
                        )
                    }
                    
                    Button(action: { levelManager.showStatistics = true }) {
                        MenuButton(
                            title: String(localized: "STATISTICS"),
                            systemImage: "chart.bar.fill"
                        )
                    }
                    
                    Button(action: { showAboutGame = true }) {
                        MenuButton(
                            title: String(localized: "ABOUT_GAME"),
                            systemImage: "info.circle"
                        )
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showLevelSelect) {
            LevelSelectView(
                levelManager: levelManager,
                startGame: selectLevel
            )
        }
        .sheet(isPresented: $showAboutGame) {
            AboutGameView()
        }
        .sheet(isPresented: $levelManager.showStatistics) {
            StatisticsView(
                statistics: levelManager.gameStatistics,
                levelManager: levelManager,
                showGame: $showGame
            )
        }
    }
}

struct MenuButton: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title3)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
            Text(title)
                .font(.title3)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        }
        .foregroundColor(.white)
        .frame(width: 280)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.3),
                    Color.blue.opacity(0.2)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(12)
    }
}

struct LevelContent: Codable {
    var number: Int // Изменено на var
    let title: String
    let description: String
    let sceneDescription: String
    let initialMessage: String
    let systemPrompt: String
    let victoryConditions: [String]
    let victoryMessage: String
}


struct AboutGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("ABOUT_TITLE")
                        .font(.title)
                        .bold()
                    
                    Group {
                        Text("ABOUT_DESCRIPTION_TITLE")
                            .font(.headline)
                        Text("ABOUT_DESCRIPTION_TEXT")
                    }
                    
                    Group {
                        Text("ABOUT_HOW_TO_PLAY")
                            .font(.headline)
                        Text("ABOUT_HOW_TO_PLAY_TEXT")
                    }
                    
                    Group {
                        Text("ABOUT_DEVELOPERS")
                            .font(.headline)
                        Text("ABOUT_DEVELOPERS_TEXT")
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("CLOSE") {
                dismiss()
            })
        }
    }
}



struct LevelSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var levelManager: LevelManager
    let startGame: (Int) -> Void
    @State private var showResetAlert = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("LEVEL_SELECT_TITLE")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(1...10, id: \.self) { level in
                                Button(action: {
                                    if levelManager.isLevelUnlocked(level) {
                                        startGame(level)
                                        dismiss()
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Image(uiImage: UIImage(named: "bgLevel\(level)") ?? UIImage(systemName: "photo.fill")!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: UIScreen.main.bounds.width / 3.5, height: 140)
                                                .clipped()
                                                .cornerRadius(15)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(Color.black.opacity(levelManager.isLevelUnlocked(level) ? 0 : 0.7))
                                                )
                                                .overlay(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                    .cornerRadius(15)
                                                )
                                            
                                            if !levelManager.isLevelUnlocked(level) {
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 30, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .shadow(radius: 5)
                                            }
                                            
                                            VStack {
                                                Spacer()
                                                Text("LEVEL \(level)")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .padding(.bottom, 10)
                                                    .shadow(radius: 5)
                                            }
                                        }
                                    }
                                }
                                .disabled(!levelManager.isLevelUnlocked(level))
                            }
                        }
                        .padding(.horizontal, 10)
                        
                        Button(action: { showResetAlert = true }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("RESET_PROGRESS")
                            }
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            })
            .alert(String(localized: "RESET_PROGRESS_TITLE"), isPresented: $showResetAlert) {
                Button(String(localized: "CANCEL"), role: .cancel) { }
                Button(String(localized: "RESET"), role: .destructive) {
                    levelManager.resetProgress()
                }
            } message: {
                Text("RESET_PROGRESS_MESSAGE")
            }
        }
    }
    
    private func getLevelTitle(_ level: Int) -> String {
        String(localized: "ERA_\(getEraKey(for: level))")
    }
    
    private func getEraKey(for level: Int) -> String {
        switch level {
        case 1: return "DAWN"
        case 2: return "EGYPT"
        case 3: return "GREECE"
        case 4: return "ROME"
        case 5: return "CHINA"
        case 6: return "MEDIEVAL"
        case 7: return "RENAISSANCE"
        case 8: return "ENLIGHTENMENT"
        case 9: return "INDUSTRIAL"
        case 10: return "MODERN"
        default: return "DAWN"
        }
    }
}

// MARK: - Models

struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let type: MessageType
    var reputationChange: Int? // Добавляем это новое свойство
    
    enum MessageType {
        case message
        case status
        case victory
        case reputationChange // Добавляем этот новый case
    }
    
    // Добавляем реализацию Equatable
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.isUser == rhs.isUser &&
        lhs.type == rhs.type &&
        lhs.reputationChange == rhs.reputationChange
    }
}


struct LevelStatistics: Codable {
    let timeSpent: TimeInterval
    let messagesCount: Int
    let totalCharacters: Int
    let startTime: Date
    let endTime: Date
}

struct GameStatistics: Codable {
    var levelsStats: [Int: LevelStatistics] = [:]
    var bestLevelStats: [Int: LevelStatistics] = [:]
    
    var totalTimeSpent: TimeInterval {
        levelsStats.values.reduce(0) { $0 + $1.timeSpent }
    }
    
    var totalMessages: Int {
        levelsStats.values.reduce(0) { $0 + $1.messagesCount }
    }
    
    var totalCharacters: Int {
        levelsStats.values.reduce(0) { $0 + $1.totalCharacters }
    }
    
    @MainActor
    mutating func updateBestStats(level: Int, stats: LevelStatistics) {
        if let currentBest = bestLevelStats[level] {
            if stats.timeSpent < currentBest.timeSpent {
                bestLevelStats[level] = stats
                save()
            }
        } else {
            bestLevelStats[level] = stats
            save()
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "GameStatistics")
        }
    }
    
    static func load() -> GameStatistics {
        if let data = UserDefaults.standard.data(forKey: "GameStatistics"),
           let decoded = try? JSONDecoder().decode(GameStatistics.self, from: data) {
            return decoded
        }
        return GameStatistics()
    }
}
// MARK: - API Models
struct AnthropicRequest: Codable {
    let model: String
    let messages: [AnthropicMessage]
    let system: String
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case system
        case maxTokens = "max_tokens"
    }
}

struct AnthropicMessage: Codable {
    let role: String
    let content: String
}


struct AnthropicContent: Codable {
    let type: String
    let text: String
}

struct AnthropicUsage: Codable {
    let inputTokens: Int
    let outputTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}


// MARK: - Services


struct AnthropicResponse: Codable {
    let content: String
}

struct APIResponse: Codable {
    let statusCode: Int
    let headers: [String: String]
    let body: String
}

class LevelService {
    static let shared = LevelService()
    private let baseURL = "https://gg40e4wjm2.execute-api.eu-north-1.amazonaws.com/prod"
    
    // Структура для декодирования ответа API Gateway
    struct APIGatewayResponse<T: Codable>: Codable {
        let statusCode: Int
        let headers: [String: String]
        let body: String
    }
        
    
    // Структура для декодирования ошибок
    struct APIErrorResponse: Codable {
        let error: String
    }
    
    
    
    func fetchLevel(_ number: Int, language: String) async throws -> LevelContent {
        print("📱 Starting to load level:", number)
        print("🌐 Fetching level content from API...")
        print("🌍 Using language:", language)
        
        guard let url = URL(string: "https://gg40e4wjm2.execute-api.eu-north-1.amazonaws.com/prod/levels") else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestDict = [
            "level": number,
            "language": language
        ] as [String : Any]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestDict)
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Request JSON being sent:", jsonString)
        }
        
        request.httpBody = jsonData
        
        print("🌐 Sending request to:", url.absoluteString)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 Response status code:", httpResponse.statusCode)
            print("📥 Response headers:", httpResponse.allHeaderFields)
            
            print("📥 Raw response data length:", data.count, "bytes")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response data as string:", responseString)
            }
            
            do {
                // Сначала декодируем обёртку API Gateway
                let gatewayResponse = try JSONDecoder().decode(APIGatewayResponse<LevelContent>.self, from: data)
                        
                        guard let levelData = gatewayResponse.body.data(using: .utf8) else {
                            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid body data"])
                        }
                        
                        return try JSONDecoder().decode(LevelContent.self, from: levelData)
                        
                    } catch {
                        print("❌ Decoding error:", error)
                        throw error
                    }
                }
        
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
    }
}

struct APIError: Codable {
    let message: String
}

class LevelManager: ObservableObject {
    @Published var currentLevel = 1
    @Published var showLevelCompleteAlert = false
    @Published var errorMessage: String?
    @Published var showStatistics = false
    @Published var gameStatistics: GameStatistics
    @Published var levelProgress: LevelProgress
    @Published var reputation = Reputation()
    @Published private(set) var currentLevelContent: LevelContent?
    @Published var currentTheme: LevelTheme = LevelTheme.forLevel(1)
    @Published private(set) var isLoading = false
    
    private var currentLevelStartTime = Date()
    private var currentMessagesCount = 0
    private var currentCharactersCount = 0
    
    init() {
        self.gameStatistics = GameStatistics.load()
        self.levelProgress = LevelProgress.load()
    }
    
    func getCurrentLevelContent() -> LevelContent? {
        return currentLevelContent
    }
    
    @MainActor
    func resetProgress() {
        levelProgress = LevelProgress(unlockedLevels: [1])
        levelProgress.save()
        objectWillChange.send()
    }
    
    @MainActor
    func loadLevel(_ level: Int) async {
        print("📱 Starting to load level:", level)
        isLoading = true
        errorMessage = nil
        
        do {
            print("🌐 Fetching level content from API...")
            let language = Locale.getSupportedLanguage()
            print("🌍 Using language:", language)
            
            let content = try await LevelService.shared.fetchLevel(level, language: language)
            print("✅ Successfully fetched level content:", content)
            
            self.currentLevel = level
            self.currentLevelContent = content
            self.currentTheme = LevelTheme.forLevel(level)
            self.resetLevelStats()
            self.levelProgress.updateLastPlayed(level) // Добавляем эту строку
            print("✅ Level content updated successfully")
            
        } catch {
            print("❌ Error loading level:", error)
            self.errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func resetLevelStats() {
        currentLevelStartTime = Date()
        currentMessagesCount = 0
        currentCharactersCount = 0
        reputation = Reputation()
    }
    
    @MainActor
    func unlockNextLevel() {
        let nextLevel = currentLevel + 1
        if nextLevel <= 10 {
            levelProgress.unlockLevel(nextLevel)
            objectWillChange.send()
        }
    }
    
    func isLevelUnlocked(_ level: Int) -> Bool {
        return levelProgress.unlockedLevels.contains(level)
    }
    
    func recordMessage(_ message: String) {
        currentMessagesCount += 1
        currentCharactersCount += message.count
    }
    
    @MainActor
    func nextLevel() async {
        completedLevel()
        unlockNextLevel()
        
        if currentLevel >= 10 {
            showStatistics = true
        } else {
            await loadLevel(currentLevel + 1)
        }
    }
    
    @MainActor
    func completedLevel() {
        let stats = LevelStatistics(
            timeSpent: Date().timeIntervalSince(currentLevelStartTime),
            messagesCount: currentMessagesCount,
            totalCharacters: currentCharactersCount,
            startTime: currentLevelStartTime,
            endTime: Date()
        )
        
        // Обновляем статистику в главном потоке
        gameStatistics.levelsStats[currentLevel] = stats
        gameStatistics.updateBestStats(level: currentLevel, stats: stats)
        
        if currentLevel >= 10 {
            showStatistics = true
        }
        
        // Сохраняем статистику
        gameStatistics.save()
    }
    
    @MainActor
    func resetGame() {
        currentLevel = 1
        gameStatistics = GameStatistics()
        gameStatistics.save()
        resetLevelStats()
        showStatistics = false
        objectWillChange.send()
    }
    
    func checkVictoryInResponse(response: String) -> Bool {
        guard let level = getCurrentLevelContent() else { return false }
        return level.victoryConditions.contains { condition in
            response.contains(condition)
        }
    }
    
    func checkLevelComplete(message: String) -> Bool {
        return message.lowercased().contains("go333")
    }
}

    @MainActor
    class ChatContextManager: ObservableObject {
        @Published private var messages: [ChatMessage] = []
        private let contextKey = "chatContext"
        private let systemPromptLoader = SystemPromptLoader.shared
        
        func getFormattedContext() -> [ChatMessage] {
            return messages
        }

        func addMessage(_ message: ChatMessage) {
            if message.role == .system && messages.contains(where: { $0.role == .system }) {
                return
            }
            messages.append(message)
            saveContext()
        }
        
        func clearContext() {
            messages.removeAll()
            UserDefaults.standard.removeObject(forKey: contextKey)
        }
        
        func initializeContext() async throws {
            let systemPrompt = try await SystemPromptLoader.shared.loadSystemPrompt()
            
            await MainActor.run {
                // Очищаем предыдущий контекст
                messages.removeAll()
                
                // Добавляем системный промпт как первое сообщение
                messages = [ChatMessage(role: .system, content: systemPrompt)]
                saveContext()
            }
        }
    
    // Остальные методы без изменений
    private func saveContext() {
        let context = messages.map { message in
            return [
                "role": message.role.rawValue,
                "content": message.content,
                "timestamp": message.timestamp
            ]
        }
        UserDefaults.standard.set(context, forKey: contextKey)
    }
    
    func loadContext() -> [ChatMessage] {
        guard let context = UserDefaults.standard.array(forKey: contextKey) as? [[String: Any]] else {
            return messages
        }
        
        return context.compactMap { dict in
            guard let roleString = dict["role"] as? String,
                  let role = ChatMessage.Role(rawValue: roleString),
                  let content = dict["content"] as? String,
                  let timestamp = dict["timestamp"] as? Date else {
                return nil
            }
            return ChatMessage(role: role, content: content, timestamp: timestamp)
        }
    }
}

struct StatisticsView: View {
    let statistics: GameStatistics
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var levelManager: LevelManager
    @Binding var showGame: Bool
    @State private var showingRestartAlert = false
    @State private var showingShareSheet = false
    
    private var shareText: String {
        let title = String(localized: "SHARE_TITLE")
        let bestResults = String(localized: "SHARE_BEST_RESULTS")
        let totalTime = String(localized: "SHARE_TOTAL_TIME")
        let totalMessages = String(localized: "SHARE_TOTAL_MESSAGES")
        let totalChars = String(localized: "SHARE_TOTAL_CHARS")
        let tryBetter = String(localized: "SHARE_TRY_BETTER")
        
        return """
        🎮 \(title)
        
        📊 \(bestResults)
        ⏱️ \(totalTime): \(formatTime(statistics.totalTimeSpent))
        💬 \(totalMessages): \(statistics.totalMessages)
        📝 \(totalChars): \(statistics.totalCharacters)
        
        🎯 \(tryBetter)
        """
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("STATISTICS_GENERAL")) {
                    StatRow(title: String(localized: "TOTAL_TIME"),
                           value: formatTime(statistics.totalTimeSpent))
                    StatRow(title: String(localized: "TOTAL_MESSAGES"),
                           value: "\(statistics.totalMessages)")
                    StatRow(title: String(localized: "CHARACTERS_TYPED"),
                           value: "\(statistics.totalCharacters)")
                }
                
                Section(header: Text("STATISTICS_BEST_TIMES")) {
                    ForEach(1...10, id: \.self) { level in
                        if let bestStats = statistics.bestLevelStats[level] {
                            Section(header: Text("LEVEL \(level)")) {
                                StatRow(title: String(localized: "BEST_TIME"),
                                       value: formatTime(bestStats.timeSpent))
                                StatRow(title: String(localized: "STATISTICS_MESSAGES"),
                                       value: "\(bestStats.messagesCount)")
                                StatRow(title: String(localized: "COMPLETION_DATE"),
                                       value: formatDate(bestStats.endTime))
                            }
                        }
                    }
                }
                
                Section(header: Text("CURRENT_SESSION")) {
                    ForEach(1...10, id: \.self) { level in
                        if let levelStats = statistics.levelsStats[level] {
                            Section(header: Text("LEVEL \(level)")) {
                                StatRow(title: String(localized: "STATISTICS_TIME"),
                                       value: formatTime(levelStats.timeSpent))
                                StatRow(title: String(localized: "STATISTICS_MESSAGES"),
                                       value: "\(levelStats.messagesCount)")
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: { showingShareSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("SHARE_RESULTS")
                        }
                    }
                    
                    Button(action: {
                        showingRestartAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("START_OVER")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(String(localized: "STATISTICS_TITLE"))
            .navigationBarItems(trailing: Button(String(localized: "CLOSE")) {
                showGame = false
                dismiss()
            })
            .alert(String(localized: "START_OVER_TITLE"), isPresented: $showingRestartAlert) {
                Button(String(localized: "CANCEL"), role: .cancel) { }
                Button(String(localized: "START_OVER_CONFIRM"), role: .destructive) {
                    restartGame()
                }
            } message: {
                Text("START_OVER_MESSAGE")
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [shareText])
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return "\(minutes)м \(seconds)с"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func restartGame() {
        levelManager.resetGame()
        showGame = false
        dismiss()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}


struct GameView: View {
    @ObservedObject var levelManager: LevelManager
    @StateObject private var chatContext = ChatContextManager()
    @State private var messageText: String = ""
    @State private var uiMessages: [Message] = []
    @State private var isLoading: Bool = false
    @Binding var showGame: Bool
    @State private var scrollProxy: ScrollViewProxy?
    @State private var reputation = Reputation()
    private let loadingIndicatorID = "loading_spinner_id"
    
    private let aiService = AIService()
    let startingLevel: Int
    
    init(startingLevel: Int, levelManager: LevelManager, showGame: Binding<Bool>) {
        self.startingLevel = startingLevel
        _levelManager = ObservedObject(wrappedValue: levelManager)
        _showGame = showGame
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar with level indicator and restart button
            HStack {
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                  to: nil,
                                                  from: nil,
                                                  for: nil) // Скрываем клавиатуру
                    showGame = false
                }) {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundColor(levelManager.currentTheme.primary)
                }
                
                Spacer()
                
                Text(String(localized: "LEVEL \(levelManager.currentLevel)"))
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                HStack(spacing: 16) {
                    ReputationIndicator(reputation: levelManager.reputation)
                    Button(action: {
                        levelManager.resetLevelStats()
                        chatContext.clearContext()
                        Task {
                            await loadLevelAndInitialize()
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.title2)
                            .foregroundColor(levelManager.currentTheme.primary)
                    }
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .shadow(radius: 1)
            
            // Main scroll view containing both image and messages
            ScrollViewReader { proxy in
                ScrollView {
                    if levelManager.isLoading {
                        ProgressView()
                    } else if let error = levelManager.errorMessage {
                        NetworkErrorView(
                            errorMessage: error,
                            retryAction: {
                                await loadLevelAndInitialize()
                            }
                        )
                    } else {
                        VStack(spacing: 12) {
                            // Level image
                            Group {
                                if let _ = UIImage(named: "bgLevel\(levelManager.currentLevel)") {
                                    Image("bgLevel\(levelManager.currentLevel)")
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                } else {
                                    Image(systemName: "person.2.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: 300)
                                        .clipped()
                                }
                            }
                            .cornerRadius(15)
                            .background(Color(uiColor: .systemGray6))
                            
                            // Messages
                            ForEach(uiMessages) { message in
                                MessageBubble(
                                    message: message,
                                    onNextLevel: {
                                        startNextLevel()
                                    }
                                )
                            }
                            .environmentObject(levelManager)
                            if isLoading {
                                LoadingIndicator(theme: levelManager.currentTheme)
                                    .id(loadingIndicatorID)
                            }
                        }
                        .padding()
                        .background(
                            Image("bgchat\(levelManager.currentLevel)")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 1000, alignment: .topLeading)
                                .edgesIgnoringSafeArea(.all)
                                .opacity(0.1)
                        )
                    }
                }
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: uiMessages) { _, _ in
                    if let lastMessage = uiMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Bottom input field
            HStack(spacing: 12) {
                TextField(String(localized: "ENTER_MESSAGE"), text: $messageText)
                    .font(.body)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: { sendMessage() }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(levelManager.currentTheme.primary)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
        }
        .alert(String(localized: "LEVEL_COMPLETE"), isPresented: $levelManager.showLevelCompleteAlert) {
            Button(String(localized: "NEXT_LEVEL")) {
                startNextLevel()
            }
        } message: {
            Text(String(format: String(localized: "LEVEL_COMPLETE"), levelManager.currentLevel))
        }
        
        .alert(String(localized: "ERROR"), isPresented: .constant(levelManager.errorMessage != nil)) {
            Button(String(localized: "RETRY")) {
                Task {
                    await loadLevelAndInitialize()
                }
                levelManager.errorMessage = nil
            }
        } message: {
            if let errorMessage = levelManager.errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $levelManager.showStatistics) {
            StatisticsView(
                statistics: levelManager.gameStatistics,
                levelManager: levelManager,
                showGame: $showGame
            )
        }
        .onAppear {
            print("🎮 GameView appeared")
            print("📊 Starting level:", startingLevel)
            Task {
                await loadLevelAndInitialize()
            }
        }
    }
    
    func formatMessageForDisplay(_ message: String) -> String {
        // Удаляем маркер победы из текста перед отображением
        return message.replacingOccurrences(of: "---VICTORY---", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractReputation(from response: String) -> (cleanResponse: String, newReputation: Int?) {
        // Ищем значение репутации в формате *REPUTATION:X*
        let pattern = #"\*REPUTATION:(\d+)\*"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: response,
                range: NSRange(response.startIndex..., in: response)
              ),
              let reputationRange = Range(match.range(at: 1), in: response),
              let newReputation = Int(response[reputationRange]) else {
            return (response, nil)
        }
        
        // Удаляем метку репутации из ответа
        let cleanResponse = regex.stringByReplacingMatches(
            in: response,
            range: NSRange(response.startIndex..., in: response),
            withTemplate: ""
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        
        return (cleanResponse, newReputation)
    }
    
    @MainActor
    private func loadInitialMessage() async {
        if let level = levelManager.getCurrentLevelContent() {
            withAnimation {
                uiMessages = [
                    Message(
                        content: String(format: NSLocalizedString("LEVEL", comment: ""), level.number) + ": \(level.title)",
                        isUser: false,
                        type: .status
                    ),
                    Message(content: level.description, isUser: false, type: .status),
                    Message(content: level.sceneDescription, isUser: false, type: .status),
                    Message(content: level.initialMessage, isUser: false, type: .message)
                ]
            }
            
            do {
                let systemPrompt = try await SystemPromptLoader.shared.loadSystemPrompt()
                
                let combinedPrompt = """
                \(systemPrompt)
                
                РОЛЬ И ХАРАКТЕР:
                \(level.systemPrompt)
                """
                
                print("📝 Combined Prompt:", combinedPrompt)
                
                chatContext.clearContext()
                chatContext.addMessage(ChatMessage(role: .system, content: combinedPrompt))
            } catch {
                print("❌ Error loading system prompt:", error)
                levelManager.errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func startNextLevel() {
        Task {
            await levelManager.nextLevel()
            chatContext.clearContext()
            await loadLevelAndInitialize()
        }
    }

    @MainActor
    private func loadLevelAndInitialize() async {
        do {
            // Загружаем уровень
            await levelManager.loadLevel(levelManager.currentLevel)
            
            // Инициализируем контекст напрямую, так как мы уже в @MainActor
            try await chatContext.initializeContext()
            
            // Загружаем начальное сообщение уровня
            await loadInitialMessage()
            
        } catch {
            levelManager.errorMessage = "ERROR: \(error.localizedDescription)"
        }
    }
    
    private func sendMessage() {
        Task {
            // 1. Проверка состояния и валидация
            guard !isLoading else { return }
            let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedMessage.isEmpty else { return }
            
            // 2. Подготовка к отправке - все UI обновления в главном потоке
            await MainActor.run {
                HapticManager.shared.messageSubmitted() // Haptic при отправке
                levelManager.recordMessage(trimmedMessage)
                appendUserMessage(trimmedMessage)
                messageText = ""
                isLoading = true
                
                // Проверка завершения уровня
                if levelManager.checkLevelComplete(message: trimmedMessage) {
                    HapticManager.shared.notifySuccess() // Haptic при завершении уровня
                    levelManager.showLevelCompleteAlert = true
                    isLoading = false
                    return
                }
                
                // Добавление в контекст
                chatContext.addMessage(ChatMessage(role: .user, content: trimmedMessage))
                
                // Прокрутка к индикатору загрузки
                scrollToLoadingIndicator()
            }
            
            do {
                print("🚀 Sending messages to API:")
                for msg in chatContext.getFormattedContext() {
                    print("Role:", msg.role)
                    print("Content:", msg.content)
                    print("---")
                }
                
                let response = try await aiService.sendMessage(messages: chatContext.getFormattedContext())
                
                // 4. Обработка ответа
                let (cleanResponse, newReputation) = extractReputation(from: response)
                
                await MainActor.run {
                    // Обновление репутации
                    if let newReputation = newReputation {
                        updateReputation(newReputation)
                    }
                    
                    // Haptic при получении ответа
                    if response.contains("---VICTORY---") {
                        HapticManager.shared.notifySuccess()
                    } else {
                        HapticManager.shared.messageReceived()
                    }
                    
                    // Отображение сообщений
                    Task {
                        await displayMessages(from: cleanResponse)
                    }
                    
                    // Добавление ответа в контекст
                    chatContext.addMessage(ChatMessage(role: .assistant, content: cleanResponse))
                    isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    HapticManager.shared.notifyError() // Haptic при ошибке
                    handleError(error)
                    isLoading = false
                }
            }
        }
    }
    
    // Вспомогательные функции
    @MainActor
    private func prepareForSending(message: String) {
        // Логирование
#if DEBUG
        logContext()
#endif
        
        // Обработка сообщения
        levelManager.recordMessage(message)
        appendUserMessage(message)
        messageText = ""
        
        // Проверка завершения уровня
        if levelManager.checkLevelComplete(message: message) {
            levelManager.showLevelCompleteAlert = true
            return
        }
        
        // Добавление в контекст
        chatContext.addMessage(ChatMessage(role: .user, content: message))
        
        // Прокрутка к индикатору загрузки
        scrollToLoadingIndicator()
    }
    
    @MainActor
    private func processResponse(_ response: String, _ originalMessage: String) async {
        let (cleanResponse, newReputation) = extractReputation(from: response)
        
        // Обновление репутации
        if let newReputation = newReputation {
            updateReputation(newReputation)
        }
        
        // Отображение сообщений
        await displayMessages(from: cleanResponse)
        
        // Добавление ответа в контекст
        chatContext.addMessage(ChatMessage(role: .assistant, content: cleanResponse))
    }
    
    @MainActor
    private func updateReputation(_ newReputation: Int) {
        let oldScore = levelManager.reputation.score
        levelManager.reputation.score = newReputation
        
        // Показываем изменение репутации
        if oldScore != newReputation {
            let change = newReputation - oldScore
            withAnimation(.spring(response: 0.3)) {
                uiMessages.append(Message(
                    content: "",
                    isUser: false,
                    type: .reputationChange,
                    reputationChange: change
                ))
            }
        }
    }
    
    @MainActor
    private func displayMessages(from response: String) async {
        // Очищаем ответ от маркера победы для отображения
        let cleanResponse = formatMessageForDisplay(response)
        
        let components = cleanResponse.components(separatedBy: "*")
        for (index, component) in components.enumerated() {
            let trimmedComponent = component.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedComponent.isEmpty {
                if let proxy = scrollProxy {
                    proxy.scrollTo(loadingIndicatorID, anchor: .bottom)
                }
                
                try? await Task.sleep(nanoseconds: 100_000_000)
                
                if index % 2 == 1 {
                    withAnimation(.spring(response: 0.3)) {
                        uiMessages.append(Message(content: trimmedComponent, isUser: false, type: .status))
                    }
                } else {
                    withAnimation(.spring(response: 0.3)) {
                        uiMessages.append(Message(content: trimmedComponent, isUser: false, type: .message))
                    }
                }
                
                // Проверяем наличие маркера победы в оригинальном ответе
                if response.contains("---VICTORY---") {
                    if let proxy = scrollProxy {
                        proxy.scrollTo(uiMessages.last?.id, anchor: .bottom)
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    
                    withAnimation(.spring(response: 0.3)) {
                        uiMessages.append(Message(
                            content: String(format: NSLocalizedString("LEVEL_VICTORY", comment: ""), levelManager.currentLevel),
                            isUser: false,
                            type: .victory
                        ))
                    }
                    break // Прерываем цикл после обработки победы
                }
                
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
        }
    }
    
    private func logContext() {
        print("\n=== ОТПРАВКА В API ===")
        let context = chatContext.getFormattedContext()
        for (index, msg) in context.enumerated() {
            print("\nСообщение \(index):")
            print("Роль: \(msg.role)")
            print("Первые 100 символов: \(String(msg.content))")
        }
        print("=== КОНЕЦ ОТПРАВКИ ===\n")
    }
    
    @MainActor
    private func scrollToLoadingIndicator() {
        if let proxy = scrollProxy {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    proxy.scrollTo(self.loadingIndicatorID, anchor: .bottom)
                }
            }
        }
    }
    
    @MainActor
    private func handleError(_ error: Error) {
        if let aiError = error as? AIService.AIError {
            switch aiError {
            case .apiError(let message):
                levelManager.errorMessage = String(format: String(localized: "API_ERROR"), message)
            case .networkError(_):
                levelManager.errorMessage = String(localized: "NETWORK_ERROR")
            case .invalidResponse:
                levelManager.errorMessage = String(localized: "INVALID_RESPONSE")
            case .overloaded:
                levelManager.errorMessage = String(localized: "SERVICE_OVERLOADED")
            case .bothProvidersFailed(let details):
                levelManager.errorMessage = String(format: String(localized: "BOTH_PROVIDERS_FAILED"), details)
            }
        } else {
            levelManager.errorMessage = String(format: String(localized: "UNKNOWN_ERROR"), error.localizedDescription)
        }
    }
    
    @MainActor
    private func appendUserMessage(_ message: String) {
        let userMessage = Message(content: message, isUser: true, type: .message)
        withAnimation(.spring(response: 0.3)) {
            uiMessages.append(userMessage)
        }
    }
    
    
    
    struct MessageBubble: View {
        let message: Message
        let onNextLevel: (() -> Void)?
        @EnvironmentObject var levelManager: LevelManager
        
        init(message: Message, onNextLevel: (() -> Void)? = nil) {
            self.message = message
            self.onNextLevel = onNextLevel
        }
        
        private var cleanContent: String {
            formatMessageForDisplay(message.content)
        }
        
        private func formatMessageForDisplay(_ message: String) -> String {
            return message.replacingOccurrences(of: "---VICTORY---", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        private func isLevelHeader(_ content: String) -> Bool {
            // Проверяем начинается ли с локализованного "LEVEL" и содержит ":"
            return content.starts(with: String(localized: "LEVEL")) && content.contains(":")
        }
        
        var body: some View {
                switch message.type {
                case .message:
                    HStack(alignment: .top) {
                        if message.isUser {
                            Spacer()
                            Text(cleanContent)
                            .font(.body)
                            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(message.isUser ? levelManager.currentTheme.primary : Color(uiColor: .systemGray5))
                            .foregroundColor(message.isUser ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 2, y: 1)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                            .padding(.leading, 60)
                    } else {
                        Text(cleanContent)
                            .font(.body)
                            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(message.isUser ? levelManager.currentTheme.primary : Color(uiColor: .systemGray5))
                            .foregroundColor(message.isUser ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 2, y: 1)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                            .padding(.trailing, 60)
                        Spacer()
                    }
                }
                .padding(.horizontal, 4)
                
                case .status:
                    VStack {
                        Text(cleanContent)
                        .font(isLevelHeader(cleanContent) ? .title3 : .subheadline)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                        .foregroundColor(isLevelHeader(cleanContent) ? .primary : .gray)
                        .fontWeight(isLevelHeader(cleanContent) ? .bold : .regular)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 1, y: 1)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                case .victory:
                    VStack(spacing: 12) {
                        Text(cleanContent)
                        .font(.headline)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                        .multilineTextAlignment(.center)
                    
                        if let victoryMessage = levelManager.getCurrentLevelContent()?.victoryMessage {
                            Text(victoryMessage)
                            .font(.subheadline)
                            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    
                        Button(action: { onNextLevel?() }) {
                            Text("NEXT_LEVEL")
                            .font(.headline)
                            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                            .foregroundColor(levelManager.currentTheme.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity)
                .background(levelManager.currentTheme.primary.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(radius: 3, y: 2)
                .padding(.horizontal, 16)
                
            case .reputationChange:
                if let change = message.reputationChange {
                    HStack {
                        Image(systemName: change > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundColor(change > 0 ? .green : .red)
                        Text(String(format: String(localized: "REPUTATION_CHANGE"),
                                   change > 0 ? "+" : "",
                                   change))
                            .font(.callout)
                            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                            .foregroundColor(change > 0 ? .green : .red)
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
#Preview {
    ContentView()
}


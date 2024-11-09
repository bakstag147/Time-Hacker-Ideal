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
                        showGame = true
                    },
                    selectLevel: { selectedLevel in
                        startLevel = selectedLevel
                        showGame = true
                    },
                    showGame: $showGame
                )
            }
        }
    }
}

struct LoadingIndicator: View {
    @State private var animationState = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.blue)
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
    
    var body: some View {
        ZStack {
            Image("bgmenu")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                
                VStack(spacing: 16) {
                    Button(action: startGame) {
                        MenuButton(title: "Начать игру", systemImage: "play.fill")
                    }
                    
                    Button(action: { showLevelSelect = true }) {
                        MenuButton(title: "Выбрать уровень", systemImage: "list.number")
                    }
                    
                    Button(action: { levelManager.showStatistics = true }) {
                        MenuButton(title: "Статистика", systemImage: "chart.bar.fill")
                    }
                    
                    Button(action: { showAboutGame = true }) {
                        MenuButton(title: "Об игре", systemImage: "info.circle")
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
            Text(title)
                .font(.mintysis(size: 24))
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
struct AboutGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("О Time Hacker")
                        .font(.title)
                        .bold()
                    
                    Group {
                        Text("Описание")
                            .font(.headline)
                        Text("Time Hacker - это игра о социальной инженерии и искусстве убеждения. Путешествуйте через разные эпохи, используя навыки коммуникации для достижения своих целей.")
                    }
                    
                    Group {
                        Text("Как играть")
                            .font(.headline)
                        Text("• Каждый уровень представляет собой диалог с персонажем из определенной эпохи\n• Используйте убеждение, знания и хитрость, чтобы достичь цели\n• Внимательно читайте описание ситуации и реакции персонажа\n• Победите, найдя правильный подход к каждому собеседнику")
                    }
                    
                    Group {
                        Text("Уровни")
                            .font(.headline)
                        Text("Игра содержит 10 уровней, каждый в своей исторической эпохе:\n1. Заря Человечества\n2. Древний Египет\n3. Древняя Греция\n4. Римская Империя\n5. Средневековый Китай\n6. Средневековая Европа\n7. Эпоха Возрождения\n8. Эпоха Просвещения\n9. Индустриальная Эпоха\n10. Современность")
                    }
                    
                    Group {
                        Text("Разработчики")
                            .font(.headline)
                        Text("Создано с ❤️ для всех любителей истории и социальной инженерии")
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Закрыть") {
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
                        Text("Выбор уровня")
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
                                                Text("Уровень \(level)")
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
                                Text("Сбросить прогресс")
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
            .alert("Сбросить прогресс?", isPresented: $showResetAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Сбросить", role: .destructive) {
                    levelManager.resetProgress()
                }
            } message: {
                Text("Все уровни, кроме первого, будут заблокированы. Статистика прохождения сохранится.")
            }
        }
    }
    
    private func getLevelTitle(_ level: Int) -> String {
        switch level {
        case 1: return "Заря Человечества"
        case 2: return "Древний Египет"
        case 3: return "Древняя Греция"
        case 4: return "Римская Империя"
        case 5: return "Средневековый Китай"
        case 6: return "Средневековая Европа"
        case 7: return "Эпоха Возрождения"
        case 8: return "Эпоха Просвещения"
        case 9: return "Индустриальная Эпоха"
        case 10: return "Современность"
        default: return ""
        }
    }
}

// MARK: - Models
enum MessageType {
    case message
    case status
    case victory
}

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
    
    // Убрали private модификатор
    mutating func save() {
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

enum AnthropicError: Error {
    case invalidResponse
    case apiError(String)
    case networkError(Error)
}

// MARK: - Services


struct AnthropicResponse: Codable {
    let content: String
}

class AnthropicService {
    private let endpoint = "https://gg40e4wjm2.execute-api.eu-north-1.amazonaws.com/prod/proxy"
    
    struct AnthropicResponse: Codable {
        let content: String
    }
    
    enum AnthropicError: Error {
        case invalidResponse
        case apiError(String)
    }
    
    func sendMessage(messages: [ChatMessage]) async throws -> String {
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "messages": messages.map { [
                "role": $0.role == .user ? "user" : "assistant",
                "content": $0.content
            ] },
            "max_tokens": 1024
        ] as [String : Any]
        
        print("=== ОТПРАВЛЯЕМЫЙ JSON ===")
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        print(String(data: jsonData, encoding: .utf8) ?? "")
        
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("=== ОТВЕТ СЕРВЕРА ===")
        print(String(data: data, encoding: .utf8) ?? "")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnthropicError.invalidResponse
        }
        
        print("Статус код: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorBody = errorData["body"] as? String {
                throw AnthropicError.apiError(errorBody)
            }
            throw AnthropicError.apiError("Статус код: \(httpResponse.statusCode)")
        }
        
        // Парсим ответ
        guard let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let bodyString = responseDict["body"] as? String,
              let bodyData = bodyString.data(using: .utf8) else {
            throw AnthropicError.invalidResponse
        }
        
        let anthropicResponse = try JSONDecoder().decode(AnthropicResponse.self, from: bodyData)
        return anthropicResponse.content
    }
}

class LevelManager: ObservableObject {
    @Published var currentLevel = 1
    @Published var showLevelCompleteAlert = false
    @Published var errorMessage: String?
    @Published var showStatistics = false
    @Published var gameStatistics: GameStatistics
    @Published var levelProgress: LevelProgress
    @Published var reputation = Reputation()
    
    private var currentLevelStartTime = Date()
    private var currentMessagesCount = 0
    private var currentCharactersCount = 0
    
    init() {
        self.gameStatistics = GameStatistics.load()
        self.levelProgress = LevelProgress.load()
    }
    
    // Добавляем метод для получения контента уровня
    func getCurrentLevelContent() -> LevelContent? {
        return LevelContent.levels[currentLevel]
    }
    func resetProgress() {
        levelProgress = LevelProgress(unlockedLevels: [1]) // Передаем Set с первым уровнем
        levelProgress.save()
        objectWillChange.send()
    }
    
    // Обновляем метод загрузки уровня
    func loadLevel(_ level: Int) {
        guard level <= 10, LevelContent.levels[level] != nil else { return }
        currentLevel = level
        resetLevelStats()
    }
    
    // Метод сброса статистики уровня
    func resetLevelStats() {
        currentLevelStartTime = Date()
        currentMessagesCount = 0
        currentCharactersCount = 0
        reputation = Reputation()
    }
    
    // Метод разблокировки следующего уровня
    func unlockNextLevel() {
        let nextLevel = currentLevel + 1
        if nextLevel <= 10 {
            levelProgress.unlockedLevels.insert(nextLevel)
            levelProgress.save()
            objectWillChange.send()
        }
    }
    
    // Проверка разблокирован ли уровень
    func isLevelUnlocked(_ level: Int) -> Bool {
        return levelProgress.unlockedLevels.contains(level)
    }
    
    func recordMessage(_ message: String) {
        currentMessagesCount += 1
        currentCharactersCount += message.count
    }
    
    func nextLevel() {
        if currentLevel < 10 {
            loadLevel(currentLevel + 1)
        }
    }
    
    func completedLevel() {
        let stats = LevelStatistics(
            timeSpent: Date().timeIntervalSince(currentLevelStartTime),
            messagesCount: currentMessagesCount,
            totalCharacters: currentCharactersCount,
            startTime: currentLevelStartTime,
            endTime: Date()
        )
        gameStatistics.levelsStats[currentLevel] = stats
        gameStatistics.updateBestStats(level: currentLevel, stats: stats)
        
        if currentLevel >= 10 {
            showStatistics = true
        }
        
        // Сохраняем статистику
        gameStatistics.save()
    }
    
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
    func updateReputation(based message: String) {
        let lowercased = message.lowercased()
        
        // Позитивные факторы
        if lowercased.contains("уважение") || lowercased.contains("прошу прощения") {
            reputation.modify(by: 5)
        }
        if lowercased.contains("традиции") || lowercased.contains("мудрость") {
            reputation.modify(by: 3)
        }
        
        // Негативные факторы
        if lowercased.contains("угроз") || lowercased.contains("застав") {
            reputation.modify(by: -10)
        }
        if lowercased.contains("требую") || lowercased.contains("немедленно") {
            reputation.modify(by: -5)
        }
    }
    
    func checkLevelComplete(message: String) -> Bool {
        return message.lowercased().contains("go333")
    }
}


class ChatContextManager: ObservableObject {
    @Published private var messages: [ChatMessage] = []
    private let contextKey = "chatContext"
    
    func getFormattedContext() -> [ChatMessage] {
        // Просто возвращаем все сообщения в правильном порядке
        return messages
    }

    func addMessage(_ message: ChatMessage) {
        // Если это системное сообщение и оно уже есть, не добавляем его повторно
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
        var text = "🎮 Time Hacker - Мои лучшие результаты:\n\n"
        
        // Добавляем информацию о лучших прохождениях
        let sortedBestStats = statistics.bestLevelStats.sorted { $0.key < $1.key }
        
        text += """
        
        📊 Моё лучшее прхождение:
        ⏱️ Общее время игры: \(formatTime(statistics.totalTimeSpent))
        💬 Всего сообщений: \(statistics.totalMessages)
        📝 Всего символов: \(statistics.totalCharacters)
        
        🎯 Попробуй лучше в Time Hacker!
        """
        
        return text
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Общая статистика")) {
                    StatRow(title: "Общее время", value: formatTime(statistics.totalTimeSpent))
                    StatRow(title: "Всего сообщений", value: "\(statistics.totalMessages)")
                    StatRow(title: "Всего символов", value: "\(statistics.totalCharacters)")
                }
                
                Section(header: Text("Лучшее время прохождения")) {
                    ForEach(1...10, id: \.self) { level in
                        if let bestStats = statistics.bestLevelStats[level] {
                            Section(header: Text("Уровень \(level)")) {
                                StatRow(title: "Лучшее время", value: formatTime(bestStats.timeSpent))
                                StatRow(title: "Сообщений", value: "\(bestStats.messagesCount)")
                                StatRow(title: "Дата прохождения", value: formatDate(bestStats.endTime))
                            }
                        }
                    }
                }
                
                Section(header: Text("Текущая сессия")) {
                    ForEach(1...10, id: \.self) { level in
                        if let levelStats = statistics.levelsStats[level] {
                            Section(header: Text("Уровень \(level)")) {
                                StatRow(title: "Время", value: formatTime(levelStats.timeSpent))
                                StatRow(title: "Сообщений", value: "\(levelStats.messagesCount)")
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: { showingShareSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Поделиться результатами")
                        }
                    }
                    
                    Button(action: {
                        showingRestartAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Начать сначала")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Статистика игры")
            .navigationBarItems(trailing: Button("Закрыть") {
                showGame = false
                dismiss()
            })
            .alert("Начать сначала?", isPresented: $showingRestartAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Начать", role: .destructive) {
                    restartGame()
                }
            } message: {
                Text("Вы уверены, что хотите начать игру сначала? Весь прогресс будет потерян.")
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
    
    private let anthropicService = AnthropicService()
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
                Text("Уровень \(levelManager.currentLevel)")
                    .font(.title2)
                    .bold()
                Text("из 10")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                ReputationIndicator(reputation: levelManager.reputation)
                Button(action: {
                    levelManager.resetLevelStats()
                    chatContext.clearContext()
                    loadInitialMessage()
                }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .shadow(radius: 1)
            
            // Main scroll view containing both image and messages
            ScrollViewReader { proxy in
                ScrollView {
                    // Убираем внешний ZStack и перемещаем фон в background
                    VStack(spacing: 12) {
                        // Level image
                        Group {
                            if let _ = UIImage(named: "bgLevel\(levelManager.currentLevel)") {
                                Image("bgLevel\(levelManager.currentLevel)")
                                    .resizable()
                                    .scaledToFill() // Изменено на Fill для полного покрытия
                                    .clipped() // Обрезает изображение по границам
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
                            LoadingIndicator()
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
                TextField("Введите сообщение...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: { sendMessage() }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
        }
        .alert("Уровень пройден!", isPresented: $levelManager.showLevelCompleteAlert) {
            Button("Следующий уровень") {
                startNextLevel()
            }
        } message: {
            Text("Поздравляем! Вы успешно прошли уровень \(levelManager.currentLevel)")
        }
        .alert("Ошибка", isPresented: .constant(levelManager.errorMessage != nil)) {
            Button("OK") {
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
            levelManager.loadLevel(startingLevel)
            loadInitialMessage()
        }
    }
    
    private func loadInitialMessage() {
        guard let level = levelManager.getCurrentLevelContent() else {
            uiMessages = [Message(content: "Ошибка загрузки уровня", isUser: false, type: .status)]
            return
        }
        
        chatContext.clearContext()
        
        uiMessages = [
            Message(content: "Уровень \(level.number): \(level.title)", isUser: false, type: .status),
            Message(content: level.description, isUser: false, type: .status),
            Message(content: level.sceneDescription, isUser: false, type: .status),
            Message(content: level.initialMessage, isUser: false, type: .message)
        ]
        
        // Объединяем базовый промпт и промпт уровня
        let combinedPrompt = """
        \(ChatMessage.systemBasePrompt)
        
        РОЛЬ И ХАРАКТЕР:
        \(level.prompt)
        """
        
        chatContext.addMessage(ChatMessage(role: .system, content: combinedPrompt))
    }
    
    private func startNextLevel() {
        levelManager.completedLevel()
        levelManager.unlockNextLevel()
        levelManager.nextLevel()
        chatContext.clearContext()
        loadInitialMessage()
    }
    
    private func sendMessage() {
        Task {
            let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedMessage.isEmpty else { return }
            
            // Отладочный вывод перед отправкой в API
            print("\n=== ОТПРАВКА В API ===")
            let context = chatContext.getFormattedContext()
            for (index, msg) in context.enumerated() {
                print("\nСообщение \(index):")
                print("Роль: \(msg.role)")
                print("Первые 100 символов: \(String(msg.content))")
            }
            print("=== КОНЕЦ ОТПРАВКИ ===\n")
            
            levelManager.recordMessage(trimmedMessage)
            
            // Обновляем репутацию на основе сообщения
            levelManager.updateReputation(based: trimmedMessage)
            
            // Если репутация изменилась, показываем это
            let oldScore = levelManager.reputation.score
            if oldScore != levelManager.reputation.score {
                let change = levelManager.reputation.score - oldScore
                withAnimation(.spring(response: 0.3)) {
                    uiMessages.append(Message(
                        content: "",
                        isUser: false,
                        type: .reputationChange,
                        reputationChange: change
                    ))
                }
            }
            
            let userMessage = Message(content: trimmedMessage, isUser: true, type: .message)
            withAnimation(.spring(response: 0.3)) {
                uiMessages.append(userMessage)
            }
            messageText = ""
            
            if levelManager.checkLevelComplete(message: trimmedMessage) {
                levelManager.showLevelCompleteAlert = true
                return
            }
            
            // Добавляем информацию о репутации в контекст
            let reputationContext = """
            Текущий уровень репутации: \(levelManager.reputation.level.rawValue)
            Уровень доверия: \(levelManager.reputation.score)/100
            """

            let updatedPrompt = (levelManager.getCurrentLevelContent()?.prompt ?? "") + "\n\n" + reputationContext
            chatContext.addMessage(ChatMessage(role: .system, content: updatedPrompt))
            chatContext.addMessage(ChatMessage(role: .user, content: trimmedMessage))

            isLoading = true
            if let proxy = scrollProxy {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        proxy.scrollTo(loadingIndicatorID, anchor: .bottom)
                    }
                }
            }
            
            do {
                let response = try await anthropicService.sendMessage(messages: chatContext.getFormattedContext())
                
                let components = response.components(separatedBy: "*")
                for (index, component) in components.enumerated() {
                    let trimmedComponent = component.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedComponent.isEmpty {
                        // Прокручиваем заранее
                        if let proxy = scrollProxy {
                            proxy.scrollTo(loadingIndicatorID, anchor: .bottom)
                        }
                        
                        // Ждем немного после прокрутки
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 секунды
                        
                        // Теперь добавляем сообщение
                        if index % 2 == 1 {
                            withAnimation(.spring(response: 0.3)) {
                                uiMessages.append(Message(content: trimmedComponent, isUser: false, type: .status))
                            }
                        } else {
                            withAnimation(.spring(response: 0.3)) {
                                uiMessages.append(Message(content: trimmedComponent, isUser: false, type: .message))
                            }
                        }
                        
                        if levelManager.checkVictoryInResponse(response: trimmedComponent) {
                            if let victoryMessage = levelManager.getCurrentLevelContent()?.victoryMessage {
                                // Снова прокручиваем перед победным сообщением
                                if let proxy = scrollProxy {
                                    proxy.scrollTo(uiMessages.last?.id, anchor: .bottom)
                                }
                                try? await Task.sleep(nanoseconds: 100_000_000)
                                
                                withAnimation(.spring(response: 0.3)) {
                                    uiMessages.append(Message(content: victoryMessage, isUser: false, type: .status))
                                    uiMessages.append(Message(
                                        content: "🎉 Поздравляем! Вы успешно прошли уровень \(levelManager.currentLevel)!",
                                        isUser: false,
                                        type: .victory
                                    ))
                                }
                            }
                        }
                        
                        // Ждем завершения анимации перед следующим сообщением
                        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 секунды
                    }
                }
                
                chatContext.addMessage(ChatMessage(role: .assistant, content: response))
            } catch let error as AnthropicError {
                switch error {
                case .apiError(let message):
                    levelManager.errorMessage = "Ошибка API: \(message)"
                case .networkError(_):
                    levelManager.errorMessage = "Ошибка сети. Проверьте подключение к интернету."
                case .invalidResponse:
                    levelManager.errorMessage = "Неверный ответ от сервера."
                }
            } catch {
                levelManager.errorMessage = "Неизвестная ошибка: \(error.localizedDescription)"
            }
            
            isLoading = false
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
        
        private func isLevelHeader(_ content: String) -> Bool {
            content.starts(with: "Уровень") && content.contains(":")
        }
        
        var body: some View {
            switch message.type {
            case .message:
                HStack(alignment: .top) {
                    if message.isUser {
                        Spacer()
                        Text(message.content)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 2, y: 1)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                            .padding(.leading, 60)
                    } else {
                        Text(message.content)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(uiColor: .systemGray5))
                            .foregroundColor(.primary)
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
                    Text(message.content)
                        .font(.system(size: isLevelHeader(message.content) ? 18 : 14))
                        .foregroundColor(isLevelHeader(message.content) ? .primary : .gray)
                        .fontWeight(isLevelHeader(message.content) ? .bold : .regular)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 1, y: 1)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
            case .victory:
                VStack(spacing: 12) {
                    Text(message.content)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 8)
                        .multilineTextAlignment(.center)
                    
                    if let victoryMessage = levelManager.getCurrentLevelContent()?.victoryMessage {
                        Text(victoryMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        onNextLevel?()
                    }) {
                        Text("Следующий уровень")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(radius: 3, y: 2)
                .padding(.horizontal, 16)
                
            case .reputationChange:
                if let change = message.reputationChange {
                    HStack {
                        Image(systemName: change > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundColor(change > 0 ? .green : .red)
                        Text("Репутация \(change > 0 ? "+" : "")\(change)")
                            .font(.caption)
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


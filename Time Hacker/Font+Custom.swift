import SwiftUI

extension Font {
    // Основные размеры для разных элементов интерфейса
    static func mintysis(size: CGFloat) -> Font {
        return .custom("Mintysis", size: size)
    }
    
    // Предустановленные стили
    static let gameTitle = mintysis(size: 40)      // Для главного заголовка
    static let menuButton = mintysis(size: 22)     // Для кнопок меню
    static let levelTitle = mintysis(size: 24)     // Для заголовков уровней
    static let message = mintysis(size: 16)        // Для сообщений в чате
    static let status = mintysis(size: 14)         // Для статусных сообщений
    static let victory = mintysis(size: 20)        // Для победных сообщений
}

// Удобный модификатор
extension View {
    func gameFont(_ size: CGFloat) -> some View {
        self.font(.mintysis(size: size))
    }
}

import Foundation

extension Locale {
    static func getCurrentLanguage() -> String {
        // Получаем предпочитаемый язык пользователя
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        // Возвращаем только первые два символа (например, "ru" вместо "ru-RU")
        return languageCode
    }
    
    static func getSupportedLanguage() -> String {
        let currentLanguage = getCurrentLanguage()
        let supportedLanguages = ["en", "ru"] // Список поддерживаемых языков
        
        return supportedLanguages.contains(currentLanguage) ? currentLanguage : "en"
    }
}

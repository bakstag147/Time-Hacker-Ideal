//
//  HapticManager.swift
//  Time Hacker
//
//  Created by Vladimir Milakov on 13.11.2024.
//
import Foundation
import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // Легкая обратная связь при отправке сообщения
    func messageSubmitted() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Более заметная обратная связь при получении сообщения
    func messageReceived() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Особая обратная связь при ошибке
    func notifyError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // Успешное завершение уровня
    func notifySuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}

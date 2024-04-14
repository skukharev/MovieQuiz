//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 26.03.2024.
//

import Foundation

/// Модель для хранения рекорда с количеством правильных ответов, общего количества вопросов и даты рекорда
struct GameRecord: Codable {
    /// Количество правильных ответов
    let correct: Int
    /// Общее количество вопросов
    let total: Int
    /// Дата рекорда
    let date: Date
    
    /// Используется для проверки лучшего рекорда, исходя из количества правильных ответов
    /// - Parameter another: Сравниваемый результат квиза
    /// - Returns: Возвращает true, если текущий рекорд является лучшим сравниваемого
    func isBetterThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
    
    /// Конструктор структуры с моделью для хранения рекорда с количеством правильных ответов, общего количества вопросов и даты рекорда
    /// - Parameters:
    ///   - correct: Рекордное количество правильных ответов на квиз
    ///   - total: Общее количество вопросов в квизе
    ///   - date: Дата рекорда
    init(correct: Int, total: Int, date: Date) {
        self.correct = correct
        self.total = total
        self.date = date
    }
}



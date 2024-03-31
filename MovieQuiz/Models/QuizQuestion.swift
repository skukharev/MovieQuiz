//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 16.03.2024.
//

import Foundation

/// Структура хранения информации о вопросе
public struct QuizQuestion {
    /// Данные изображения фильма
    let image: Data
    /// Строка с вопросом о рейтинге фильма
    let text: String
    /// Булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}

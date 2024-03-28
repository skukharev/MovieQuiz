//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 16.03.2024.
//

import Foundation
import UIKit

/// Структура хранения элементов управления для вопроса
public struct QuizStepViewModel {
    /// Картинка с афишей фильма с типом UIImage
    let image: UIImage
    /// Вопрос о рейтинге квиза
    let question: String
    /// Строка с порядковым номером этого вопроса (ex. "1/10")
    let questionNumber: String
}

//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 21.04.2024.
//

import Foundation
import UIKit

/// Презентер приложения
class MovieQuizPresenter {
    /// Общее количество вопросов в одном квизе
    let questionsAmount: Int = 10

    /// Переменная с индексом текущего вопроса, начальное значение 0 (по этому индексу будем искать вопрос в массиве,
    /// где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex: Int = 0

    /// Используется для перевода квиза на следующий вопрос
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    /// Ипользуется для перевода квиза на начальное состояние - первый вопрос
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    /// Используется для определения окончания квиза
    /// - Returns: возвращает true, если пользователь ответил на последний вопрос в квизе; в противном случе - false
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount-1
    }

    /// Метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    /// - Parameter model: Структура с параметрами вопроса
    /// - Returns: Структура с view model вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let picture = UIImage(data: model.image) ?? UIImage()
        let questionNumberText: String = (currentQuestionIndex+1).intToString+"/"+questionsAmount.intToString

        return QuizStepViewModel(image: picture, question: model.text, questionNumber: questionNumberText)
    }

}

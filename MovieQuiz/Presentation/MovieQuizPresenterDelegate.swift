//
//  MovieQuizPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 21.04.2024.
//

import Foundation

protocol MovieQuizPresenterDelegate: AnyObject {
    func inButtonTapHandler() -> Bool
    func raiseButtonTapHandler()
    func resetButtonTapHandler()
    func showAnswerResult(isCorrect: Bool)
    func restartQuiz()
    func requestNextQuestion()
    func show(quiz: QuizStepViewModel)
}

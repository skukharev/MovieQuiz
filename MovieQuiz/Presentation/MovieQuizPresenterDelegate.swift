//
//  MovieQuizPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 21.04.2024.
//

import Foundation

protocol MovieQuizPresenterDelegate: AnyObject {
    func highlightImageBorder(isCorrectAnswer: Bool)
    func show(quiz: QuizStepViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

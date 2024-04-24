//
//  MovieQuizViewControllerMock.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 24.04.2024.
//

import Foundation

final class MovieQuizViewControllerMock: MovieQuizPresenterDelegate {
    func show(quiz step: QuizStepViewModel) {
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
    }

    func showLoadingIndicator() {
    }

    func hideLoadingIndicator() {
    }
}

//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 21.04.2024.
//

import Foundation
import UIKit

enum AnswerButton {
    case yesButton
    case noButton
}

/// Презентер приложения
final class MovieQuizPresenter {
    weak var viewController: MovieQuizPresenterDelegate?
    /// Общее количество вопросов в одном квизе
    let questionsAmount: Int = 10
    /// Переменная с индексом текущего вопроса, начальное значение 0 (по этому индексу будем искать вопрос в массиве,
    /// где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex: Int = 0
    /// Переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers: Int = 0

    private var currentQuestion: QuizQuestion?
    private let gameStatistic = StatisticServiceImplementation()
    private var alertPresenter: AlertPresenterProtocol?

    init (viewController: MovieQuizPresenterDelegate? = nil) {
        self.viewController = viewController
        alertPresenter = AlertPresenter(view: viewController as? UIViewController)
   }

    /// Используется для перевода квиза на следующий вопрос
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    /// Ипользуется для перевода квиза на начальное состояние - первый вопрос
    func resetQuestionIndex() {
        currentQuestionIndex = 0
        correctAnswers = 0
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

    /// Обработчик нажатия на кнопки, реализует логику подсчёта и вывод результатов квиза
    /// - Parameter button: нажатая кнопка: ДА (.yes) либо НЕТ (.no)
    func buttonPressHandler(button: AnswerButton) {
        guard let viewController = viewController else {
            return
        }
        if viewController.inButtonTapHandler() {
            return
        }
        viewController.raiseButtonTapHandler()

        guard let currentQuestion = currentQuestion else {
            viewController.resetButtonTapHandler()
            return
        }
        let buttonBoolView = button == .yesButton ? true : false
        let isAnswerCorrected = currentQuestion.correctAnswer == buttonBoolView

        let impactGenerator = UINotificationFeedbackGenerator()
        let impactMethod: UINotificationFeedbackGenerator.FeedbackType = isAnswerCorrected ? .success : .error
        impactGenerator.notificationOccurred(impactMethod)

        viewController.showAnswerResult(isCorrect: isAnswerCorrected)
        switchToNextQuestion()
        if isAnswerCorrected {
            correctAnswers += 1
        }

        if isLastQuestion() {
            gameStatistic.store(correct: correctAnswers, total: questionsAmount)
            let text = """
                        Ваш результат: \(correctAnswers.intToString)/\(questionsAmount.intToString)
                        Количество сыгранных квизов: \(gameStatistic.gamesCount.intToString)
                        Рекорд: \(gameStatistic.bestGame.correct.intToString)/\(gameStatistic.bestGame.total.intToString) (\(gameStatistic.bestGame.date.dateTimeString))
                        Средняя точность: \(gameStatistic.totalAccuracy.percentToString(fractionalLength: 2))
                        """
            alertPresenter?.showAlert(alert: AlertModel(title: "Этот раунд окончен!",
                                                        message: text,
                                                        buttonText: "Сыграть ещё раз!",
                                                        completion: { [weak self] _ in
                self?.viewController?.restartQuiz()
            }))
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                self?.viewController?.requestNextQuestion()
            }
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}

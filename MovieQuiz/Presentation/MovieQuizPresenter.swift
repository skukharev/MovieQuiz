//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 21.04.2024.
//

import Foundation
import UIKit

/// Презентер приложения
final class MovieQuizPresenter: QuestionFactoryDelegate {
    /// Общее количество вопросов в одном квизе
    private let questionsAmount: Int = 10
    /// Переменная с индексом текущего вопроса, начальное значение 0 (по этому индексу будем искать вопрос в массиве,
    /// где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex: Int = 0
    /// Переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers: Int = 0
    /// Переменная для проверки нажатия на кнопку во время ожидания показа следующего слайда
    private var inButtonPressHandler = false

    weak var viewController: MovieQuizPresenterDelegate?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let gameStatistic: StatisticServiceProtocol?
    private var alertPresenter: AlertPresenterProtocol?

    init (viewController: MovieQuizPresenterDelegate? = nil) {
        self.viewController = viewController
        alertPresenter = AlertPresenter(view: viewController as? UIViewController)
        gameStatistic = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }

    /// Используется для перевода квиза на следующий вопрос
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    /// Ипользуется для перевода квиза на начальное состояние - первый вопрос
    private func resetQuestionIndex() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }

    /// Используется для определения окончания квиза
    /// - Returns: возвращает true, если пользователь ответил на последний вопрос в квизе; в противном случе - false
    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount
    }

    /// Метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    /// - Parameter model: Структура с параметрами вопроса
    /// - Returns: Структура с view model вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let picture = UIImage(data: model.image) ?? UIImage()
        let questionNumberText: String = (currentQuestionIndex + 1).intToString + "/" + questionsAmount.intToString

        return QuizStepViewModel(image: picture, question: model.text, questionNumber: questionNumberText)
    }

    /// Обработчик нажатия на кнопки, реализует логику подсчёта и вывод результатов квиза
    /// - Parameter button: нажатая кнопка: ДА (.yes) либо НЕТ (.no)
    func buttonPressHandler(button: AnswerButton) {
        guard let viewController = viewController else {
            return
        }
        if inButtonPressHandler {
            return
        }
        inButtonPressHandler = true

        guard let currentQuestion = currentQuestion else {
            inButtonPressHandler = false
            return
        }
        let buttonBoolView = button == .yesButton ? true : false
        let isAnswerCorrected = currentQuestion.correctAnswer == buttonBoolView

        let impactGenerator = UINotificationFeedbackGenerator()
        let impactMethod: UINotificationFeedbackGenerator.FeedbackType = isAnswerCorrected ? .success : .error
        impactGenerator.notificationOccurred(impactMethod)

        viewController.highlightImageBorder(isCorrectAnswer: isAnswerCorrected)
        if isAnswerCorrected {
            correctAnswers += 1
        }
        switchToNextQuestion()

        if isLastQuestion() {
            if let gameStatistic = gameStatistic {
                gameStatistic.store(correct: correctAnswers, total: questionsAmount)
                let text = """
                        Ваш результат: \(correctAnswers.intToString)/\(questionsAmount.intToString)
                        Количество сыгранных квизов: \(gameStatistic.gamesCount.intToString)
                        Рекорд: \(gameStatistic.bestGame.correct.intToString)/\(gameStatistic.bestGame.total.intToString) (\(gameStatistic.bestGame.date.dateTimeString))
                        Средняя точность: \(gameStatistic.totalAccuracy.percentToString(fractionalLength: 2))
                        """
                alertPresenter?.showAlert(alert: AlertModel(
                    title: "Этот раунд окончен!",
                    message: text,
                    buttonText: "Сыграть ещё раз!",
                    completion: { [weak self] _ in
                                    self?.restartQuiz()
                                }))
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                self?.questionFactory?.requestNextQuestion()
            }
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        inButtonPressHandler = false
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    private func restartQuiz() {
        resetQuestionIndex()
        questionFactory?.requestNextQuestion()
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        restartQuiz()
    }

    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription) {[weak self] _ in
            guard let self = self else {
                return
            }
            viewController?.showLoadingIndicator()
            questionFactory?.loadData()
        }
    }

    func didFailToLoadImage(with error: any Error) {
        showNetworkError(message: error.localizedDescription) {[weak self] _ in
            guard let self = self else {
                return
            }
            questionFactory?.requestNextQuestion()
        }
    }

    private func showNetworkError(message: String, handler: ((UIAlertAction) -> Void)?) {
        viewController?.hideLoadingIndicator() // скрываем индикатор загрузки

        alertPresenter?.showAlert(alert: AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: handler))
    }

    func showLoadingIndicator() {
        viewController?.showLoadingIndicator()
    }

    func hideLoadingIndicator() {
        viewController?.hideLoadingIndicator()
    }
}

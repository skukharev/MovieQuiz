import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private var gameStatistic: StatisticServiceProtocol?
    private let presenter = MovieQuizPresenter()

    private enum AnswerButton {
        case yesButton
        case noButton
    }

    /// Переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers: Int = 0
    /// Переменная для проверки нажатия на кнопку во время ожидания показа следующего слайда
    private var inButtonPressHandler: Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(view: self)
        gameStatistic = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.show(quiz: viewModel)
        }
    }

    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        buttonPressHandler(button: AnswerButton.yesButton)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        buttonPressHandler(button: AnswerButton.noButton)
    }

    /// Выводит  на экран вопрос, который принимает на вход вью модель вопроса и ничего не возвращает
    /// - Parameter step: вью модель вопроса
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderWidth = 0
        inButtonPressHandler = false
    }

    /// Изменяет цвет рамки, принимая на вход булевое значение, отражающее статус ответа на вопрос
    /// - Parameter isCorrect: булевое значение, отражающее статус ответа на вопрос
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    /// Обработчик нажатия на кнопки, реализует логику подсчёта и вывод результатов квиза
    /// - Parameter button: нажатая кнопка: ДА (.yes) либо НЕТ (.no)
    private func buttonPressHandler(button: AnswerButton) {
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

        showAnswerResult(isCorrect: isAnswerCorrected)
        presenter.switchToNextQuestion()
        if isAnswerCorrected {
            correctAnswers += 1
        }

        if presenter.isLastQuestion() {
            if let gameStatistic = gameStatistic {
                gameStatistic.store(correct: correctAnswers, total: presenter.questionsAmount)
                let text = """
                            Ваш результат: \(correctAnswers.intToString)/\(presenter.questionsAmount.intToString)
                            Количество сыгранных квизов: \(gameStatistic.gamesCount.intToString)
                            Рекорд: \(gameStatistic.bestGame.correct.intToString)/\(gameStatistic.bestGame.total.intToString) (\(gameStatistic.bestGame.date.dateTimeString))
                            Средняя точность: \(gameStatistic.totalAccuracy.percentToString(fractionalLength: 2))
                            """
                alertPresenter?.showAlert(alert: AlertModel(title: "Этот раунд окончен!",
                                                           message: text,
                                                           buttonText: "Сыграть ещё раз!",
                                                           completion: {[weak self] _ in
                                                                        guard let self = self else {
                                                                            return
                                                                        }
                                                                        self.restartQuiz()}))
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                guard let self = self else {
                    return
                }
                self.questionFactory?.requestNextQuestion()
            }
        }
    }

    /// Обнуляет текущие результаты квиза и перезапускает квиз
    private func restartQuiz() {
        guard let questionFactory = questionFactory else {
            return
        }

        correctAnswers = 0
        presenter.resetQuestionIndex()

        questionFactory.requestNextQuestion()
    }

    /// Отображает индикатор загрузки данных
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }

    /// Скрывает индикатор загрузки данных
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String, handler: ((UIAlertAction) -> Void)?) {
        hideLoadingIndicator() // скрываем индикатор загрузки

        alertPresenter?.showAlert(alert: AlertModel(title: "Что-то пошло не так(",
                                                    message: message,
                                                    buttonText: "Попробовать ещё раз",
                                                    completion: handler))
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        restartQuiz()
    }

    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription) {[weak self] _ in
            guard let self = self else {
                return
            }
            showLoadingIndicator()
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
}

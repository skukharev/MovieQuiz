import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, MovieQuizPresenterDelegate {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var questionFactory: QuestionFactoryProtocol?
    private var presenter: MovieQuizPresenter?
    private var alertPresenter: AlertPresenterProtocol?

    /// Переменная для проверки нажатия на кнопку во время ожидания показа следующего слайда
    private var inButtonPressHandler: Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(view: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter?.didReceiveNextQuestion(question: question)
    }

    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter?.buttonPressHandler(button: AnswerButton.yesButton)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter?.buttonPressHandler(button: AnswerButton.noButton)
    }

    /// Выводит  на экран вопрос, который принимает на вход вью модель вопроса и ничего не возвращает
    /// - Parameter step: вью модель вопроса
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderWidth = 0
        inButtonPressHandler = false
    }

    /// Изменяет цвет рамки, принимая на вход булевое значение, отражающее статус ответа на вопрос
    /// - Parameter isCorrect: булевое значение, отражающее статус ответа на вопрос
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    /// Обнуляет текущие результаты квиза и перезапускает квиз
    func restartQuiz() {
        guard let questionFactory = questionFactory, let presenter = presenter else {
            return
        }

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

    /// Используется для определения, закончил ли работу обработчик события нажатия кнопок presenter.buttonPressHandler
    /// - Returns: Возвращает true, если обработчик presenter.buttonPressHandler не закончил обработку события нажатия кнопки; возвращает false в противном случае
    func inButtonTapHandler() -> Bool {
        return inButtonPressHandler
    }

    /// Используется для сброса флага работы обработчика события нажатия кнопок "Да" и "Нет" на сториборде
    func resetButtonTapHandler() {
        inButtonPressHandler = false
    }

    /// Используется для установки флага работы обработчика события нажатия кнопок "Да" и "Нет" на сториборде
    func raiseButtonTapHandler() {
        inButtonPressHandler = true
    }

    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
}

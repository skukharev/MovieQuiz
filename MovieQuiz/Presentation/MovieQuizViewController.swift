import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizPresenterDelegate, MovieQuizViewControllerProtocol {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var presenter: MovieQuizPresenter?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
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
    }

    /// Изменяет цвет рамки, принимая на вход булевое значение, отражающее статус ответа на вопрос
    /// - Parameter isCorrect: булевое значение, отражающее статус ответа на вопрос
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    /// Отображает индикатор загрузки данных
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }

    /// Скрывает индикатор загрузки данных
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}

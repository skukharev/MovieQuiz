import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    
    private struct QuizQuestion {
        /// Строка с названием фильма, совпадает с названием картинки афиши фильма в Assets
        let image: String
        /// Строка с вопросом о рейтинге фильма
        let text: String
        /// Булевое значение (true, false), правильный ответ на вопрос
        let correctAnswer: Bool
    }
    
    private struct QuizStepViewModel {
        /// Картинка с афишей фильма с типом UIImage
        let image: UIImage
        /// Вопрос о рейтинге квиза
        let question: String
        /// Строка с порядковым номером этого вопроса (ex. "1/10")
        let questionNumber: String
    }
    
    private enum AnswerButton {
        case yes
        case no
    }
    
    private let questions: [QuizQuestion] = [QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)]
    
    /// Переменная с индексом текущего вопроса, начальное значение 0 (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex: Int = 0
    /// Переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers: Int = 0
    /// Переменная для проверки нажатия на кнопку во время ожидания показа следующего слайда
    private var inButtonPressHandler: Bool = false
    /// Переменная для хранения рекорда сыгранных квизов
    private var correctAnswersRecord: Int = 0
    /// Переменная для хранения даты и времени рекорда сыгранных квизов
    private var correctAnswersRecordDateTime: Date = Date()
    /// Переменная для хранения количества сыгранных квизов
    private var numberOfQuizzesPlayed: Int = 0
    /// Переменная для хранения общего количества правильных ответов
    private var correctAnswersTotal: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        buttonPressHandler(button: AnswerButton.yes)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        buttonPressHandler(button: AnswerButton.no)
    }
    
    /// Метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    /// - Parameter model: Структура с параметрами вопроса
    /// - Returns: Структура с view model вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let picture = UIImage(named: model.image) ?? UIImage()
        let questionNumberText: String = (currentQuestionIndex+1).intToString+"/"+questions.count.intToString
        
        return QuizStepViewModel(image: picture, question: model.text, questionNumber: questionNumberText)
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
    private func buttonPressHandler(button: AnswerButton){
        if inButtonPressHandler {
            return
        }
        inButtonPressHandler = true

        let buttonBoolView = button == .yes ? true : false
        let isAnswerCorrected = questions[currentQuestionIndex].correctAnswer == buttonBoolView

        let impactGenerator = UINotificationFeedbackGenerator()
        let impactMethod: UINotificationFeedbackGenerator.FeedbackType = isAnswerCorrected ? .success : .error
        impactGenerator.notificationOccurred(impactMethod)

        showAnswerResult(isCorrect: isAnswerCorrected)
        currentQuestionIndex += 1
        if isAnswerCorrected {
            correctAnswers += 1
        }

        if currentQuestionIndex <= questions.count-1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.show(quiz: self.convert(model: self.questions[self.currentQuestionIndex]))
            }
        } else {
            if correctAnswers > correctAnswersRecord {
                correctAnswersRecord = correctAnswers
                correctAnswersRecordDateTime = Date()
            }
            numberOfQuizzesPlayed += 1
            correctAnswersTotal += correctAnswers
            let averageCorrectAnswers = Double(correctAnswersTotal) / Double(questions.count * numberOfQuizzesPlayed)
            let message = """
            Ваш результат: \(correctAnswers.intToString)/\(questions.count.intToString)
            Количество сыгранных квизов: \(numberOfQuizzesPlayed.intToString)
            Рекорд: \(correctAnswersRecord.intToString)/\(questions.count.intToString) (\(correctAnswersRecordDateTime.dateTimeString))
            Средняя точность: \(averageCorrectAnswers.percentToString(fractionalLength: 2))
            """
            let alertView = UIAlertController(title: "Этот раунд окончен!", message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Сыграть ещё раз", style: .default, handler: { action in self.restartQuiz() }))
            self.present(alertView, animated: true)
        }
    }
    
    /// Обнуляет текущие результаты квиза и перезапускает квиз
    private func restartQuiz() {
        correctAnswers = 0
        currentQuestionIndex = 0
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
}

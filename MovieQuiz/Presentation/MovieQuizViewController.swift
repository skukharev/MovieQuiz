import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet weak private var counterLabel: UILabel!;
    @IBOutlet weak private var imageView: UIImageView!;
    @IBOutlet weak private var textLabel: UILabel!;
    
    private struct QuizQuestion {
        // строка с названием фильма,
        // совпадает с названием картинки афиши фильма в Assets
        let image: String
        // строка с вопросом о рейтинге фильма
        let text: String
        // булевое значение (true, false), правильный ответ на вопрос
        let correctAnswer: Bool
    }
    
    // вью модель для состояния "Вопрос показан"
    private struct QuizStepViewModel {
        // картинка с афишей фильма с типом UIImage
        let image: UIImage
        // вопрос о рейтинге квиза
        let question: String
        // строка с порядковым номером этого вопроса (ex. "1/10")
        let questionNumber: String
    }
    
    private enum AnswerButton {
        case yes;
        case no;
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
                                             QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)];
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex: Int = 0;
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers: Int = 0;
    // переменная для проверки нажатия на кнопку во время ожидания показа следующего слайда
    private var inButtonPressHandler: Bool = false;
    // переменная для хранения рекорда сыгранных квизов
    private var correctAnswersRecord: Int = 0;
    // переменная для хранения даты и времени рекорда сыгранных квизов
    private var correctAnswersRecordDateTime: Date = Date();
    // переменная для хранения количества сыгранных квизов
    private var numberOfQuizzesPlayed: Int = 0;
    // переменная для хранения общего количества правильных ответов
    private var correctAnswersTotal: Int = 0;
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad();
        
        show(quiz: convert(model: questions[currentQuestionIndex]));
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        buttonPressHandler(button: AnswerButton.yes);
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        buttonPressHandler(button: AnswerButton.no);
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        var picture: UIImage;
        if let image: UIImage = UIImage.init(named: model.image) {
            picture = image;
        } else {
            picture = UIImage();
        }
        let questionNumberText: String = (currentQuestionIndex+1).intToString+"/"+questions.count.intToString;
        
        return QuizStepViewModel(image: picture, question: model.text, questionNumber: questionNumberText);
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber;
        imageView.image = step.image;
        textLabel.text = step.question;
        imageView.layer.masksToBounds = false;
        imageView.layer.borderWidth = 0;
        imageView.layer.cornerRadius = 0;
        
        inButtonPressHandler = false;
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        // метод красит рамку
        imageView.layer.masksToBounds = true;
        imageView.layer.borderWidth = 8;
        imageView.layer.cornerRadius = 20;
        imageView.layer.borderColor = (isCorrect) ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor;
    }
    
    //приватный метод, который обрабатывает нажатия кнопок
    //принимает на вход тип нажатой кнопки и ничего не возвращает
    private func buttonPressHandler(button: AnswerButton){
        if (inButtonPressHandler) {
            return;
        }
        inButtonPressHandler = true;
        let impactHeavy = UIImpactFeedbackGenerator(style: .light);
        impactHeavy.impactOccurred();

        let buttonBoolView: Bool = (button == .yes) ? true : false;
        let isAnswerCorrected: Bool = (questions[currentQuestionIndex].correctAnswer == buttonBoolView);
        showAnswerResult(isCorrect: isAnswerCorrected);
        currentQuestionIndex += 1;
        if (isAnswerCorrected) {
            correctAnswers += 1;
        }

        if (currentQuestionIndex <= questions.count-1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.show(quiz: self.convert(model: self.questions[self.currentQuestionIndex]));
            }
        } else {
            if (correctAnswers > correctAnswersRecord) {
                correctAnswersRecord = correctAnswers;
                correctAnswersRecordDateTime = Date();
            }
            numberOfQuizzesPlayed += 1;
            correctAnswersTotal += correctAnswers;
            let averageCorrectAnswers: Double = Double(correctAnswersTotal) / Double(questions.count * numberOfQuizzesPlayed);
            var message: String = "Ваш результат: "+correctAnswers.intToString+"/"+questions.count.intToString+"\n";
            message += "Количество сыгранных квизов: "+numberOfQuizzesPlayed.intToString+"\n";
            message += "Рекорд: "+correctAnswersRecord.intToString+"/"+questions.count.intToString+" ("+correctAnswersRecordDateTime.dateTimeString+")"+"\n";
            message += "Средняя точность: "+averageCorrectAnswers.percentToString(fractionalLength: 2);
            let alertView = UIAlertController(title: "Этот раунд окончен!", message: message, preferredStyle: .alert);
            alertView.addAction(UIAlertAction(title: "Сыграть ещё раз", style: .default, handler: { action in self.restartQuiz() }));
            self.present(alertView, animated: true);
        }
    }
    
    private func restartQuiz() {
        correctAnswers = 0;
        currentQuestionIndex = 0;
        show(quiz: convert(model: questions[currentQuestionIndex]));
    }
}

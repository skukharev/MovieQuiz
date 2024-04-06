//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 16.03.2024.
//

import Foundation


/// Класс для хранения массива вопросов и метода возврата случайного вопроса
final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoadingProtocol
    weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private let imageCache = NSCache<AnyObject, AnyObject>()

    init (moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate? = nil) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func setDelegate(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func loadData() {
        let utilityQueue = DispatchQueue(label: "utility", qos: .utility)
        
        utilityQueue.async {[weak self] in
            guard let self = self else {
                return
            }
            self.moviesLoader.loadMovies{result in
                DispatchQueue.main.async{
                    switch result {
                    case .success(let mostPopularMovies):
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    case .failure(let error):
                        self.delegate?.didFailToLoadData(with: error) 
                    }
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async(qos: .utility) {[weak self] in
            guard let self = self else {
                return
            }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.delegate?.showLoadingIndicator()
            }
            
            var imageData = Data()
            do {
                //TODO: заменить на загрузку асинхронным способом
                if let imageDataFromCache = imageCache.object(forKey: movie.resizedImageURL as AnyObject) as? Data {
                    imageData = imageDataFromCache
                } else {
                    imageData = try Data(contentsOf: movie.resizedImageURL)
                    imageCache.setObject(imageData as AnyObject, forKey: movie.resizedImageURL as AnyObject)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.delegate?.hideLoadingIndicator()
                    self.delegate?.didFailToLoadImage(with: error)
                }
            }
            let questionText = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = movie.rating > 7 ? true : false
            let question = QuizQuestion(image: imageData, text: questionText, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.delegate?.hideLoadingIndicator()
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}

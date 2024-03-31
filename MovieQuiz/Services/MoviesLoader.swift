//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 31.03.2024.
//

import Foundation

/// Протокол загрузчика данных  о кинофильмах
protocol MoviesLoadingProtocol {
    /// Загружает данные о кинофильмах в структуру MostPopularMovies
    /// - Parameter handler: Обработчик завершения загрузки данных.
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoadingProtocol {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
           // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
           guard let url = URL(string: "https://tv-api.com/en/API/MostPopularMovies/k_zcuw1ytf") else {
               preconditionFailure("Unable to construct mostPopularMoviesUrl")
           }
           return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) {result in
            switch result {
            case .success(let data):
                do {
                    var mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    mostPopularMovies.items.removeAll(where: {$0.rating == 0})
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

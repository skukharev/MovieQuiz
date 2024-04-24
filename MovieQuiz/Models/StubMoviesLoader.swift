//
//  StubMoviesLoader.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 24.04.2024.
//

import Foundation

struct StubMoviesLoader: MoviesLoadingProtocol {
    let emulateError: Bool // этот параметр нужен, чтобы заглушка эмулировала либо ошибку сети, либо успешный ответ

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test))
        } else {
            do {
                let movies = try JSONDecoder().decode(MostPopularMovies.self, from: expectedResponse)
                handler(.success(movies))} catch {
                handler(.failure(TestError.test))
            }
        }
    }

    private var expectedResponse: Data {
        """
        {
            "errorMessage" : "",
            "items" : [
                {
                    "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                    "fullTitle" : "Prey (2022)",
                    "id" : "tt11866324",
                    "imDbRating" : "7.2",
                    "imDbRatingCount" : "93332",
                    "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                    "rank" : "1",
                    "rankUpDown" : "+23",
                    "title" : "Prey",
                    "year" : "2022"
                },
                {
                    "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                    "fullTitle" : "The Gray Man (2022)",
                    "id" : "tt1649418",
                    "imDbRating" : "6.5",
                    "imDbRatingCount" : "132890",
                    "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                    "rank" : "2",
                    "rankUpDown" : "-1",
                    "title" : "The Gray Man",
                    "year" : "2022"
                }
            ]
        }
        """.data(using: .utf8) ?? Data()
    }
}

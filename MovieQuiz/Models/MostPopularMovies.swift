//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 31.03.2024.
//

import Foundation

/// Структура для хранения json-структуры с фильмами
struct MostPopularMovies: Codable {
    /// Сообщение об ошибке
    var errorMessage: String
    /// Массив с информацией о фильмах
    var items: [MostPopularMovie]
    func convertToCache() -> MostPopularMoviesCache {
        var movies = MostPopularMoviesCache(errorMessage: errorMessage, items: [])
        for movie in items {
            movies.items.append(MostPopularMovieCache(
                title: movie.title,
                rating: movie.rating,
                imageURL: movie.imageURL))
        }
        return(movies)
    }
}

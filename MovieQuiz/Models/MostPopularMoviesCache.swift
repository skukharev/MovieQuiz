//
//  MostPopularMoviesCache.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 24.04.2024.
//

import Foundation

struct MostPopularMoviesCache: Codable {
    let errorMessage: String
    var items: [MostPopularMovieCache]
    func convertFromCache() -> MostPopularMovies {
        var movies = MostPopularMovies(errorMessage: errorMessage, items: [])
        for movie in items {
            movies.items.append(MostPopularMovie(title: movie.title, rating: movie.rating, imageURL: movie.imageURL))
        }
        return(movies)
    }
}

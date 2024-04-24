//
//  MostPopularMovieCache.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 24.04.2024.
//

import Foundation

struct MostPopularMovieCache: Codable {
    let title: String
    let rating: Double
    let imageURL: URL
}

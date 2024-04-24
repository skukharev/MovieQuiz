//
//  MostPopularMoviesCodingKeys.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 24.04.2024.
//

import Foundation

enum MostPopularMoviesCodingKeys: String, CodingKey {
    case title = "fullTitle"
    case rating = "imDbRating"
    case imageURL = "image"
}

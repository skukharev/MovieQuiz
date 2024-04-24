//
//  LoadMoviesError.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 24.04.2024.
//

import Foundation

enum LoadMoviesError: Error {
    case noCacheItem
    case otherNetworkError(String)
}

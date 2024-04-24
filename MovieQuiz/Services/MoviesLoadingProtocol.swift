//
//  MoviesLoadingProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 24.04.2024.
//

import Foundation

/// Протокол загрузчика данных  о кинофильмах
protocol MoviesLoadingProtocol {
    /// Загружает данные о кинофильмах в структуру MostPopularMovies
    /// - Parameter handler: Обработчик завершения загрузки данных.
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

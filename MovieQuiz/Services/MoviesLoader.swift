//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 31.03.2024.
//

import Foundation

typealias MoviesCache = Cache<String, MostPopularMoviesCache>

/// Протокол загрузчика данных  о кинофильмах
protocol MoviesLoadingProtocol {
    /// Загружает данные о кинофильмах в структуру MostPopularMovies
    /// - Parameter handler: Обработчик завершения загрузки данных.
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

enum cacheKeys: String {
    case cacheFileName = "mainCache"
    case moviesCacheKey = "structValue"
}

enum LoadMoviesError: Error {
    case noCacheItem
    case otherNetworkError(String)
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
        do {
            let cache = try MoviesCache.loadFromDisk(withName: cacheKeys.cacheFileName.rawValue)
            if let cachedMovies = cache[cacheKeys.moviesCacheKey.rawValue] {
                let movies = cachedMovies.convertFromCache()
                handler(.success(movies))
                return
            } else {
                throw LoadMoviesError.noCacheItem
            }
        } catch let error {
            print(error.localizedDescription)
        }

        networkClient.fetch(url: mostPopularMoviesUrl) {result in
            switch result {
            case .success(let data):
                do {
                    var movies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    if movies.errorMessage != "" {
                        throw movies.errorMessage
                    }
                    movies.items.removeAll(where: {$0.rating == 0})
                    do {
                        let cache = MoviesCache.init(entryLifetime: 60 * 60 * 24 * 7, maximumEntryCount: 1)
                        cache[cacheKeys.moviesCacheKey.rawValue] = movies.convertToCache()
                        try cache.saveToDisk(withName: cacheKeys.cacheFileName.rawValue)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    handler(.success(movies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

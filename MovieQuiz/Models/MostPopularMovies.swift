//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 31.03.2024.
//

import Foundation

/// Структура для хранения json-данных о фильме
struct MostPopularMovie: Codable {
    /// Название фильма
    let title: String
    /// Рейтинг фильма
    let rating: Double
    /// url с обложкой фильма
    let imageURL: URL
    
    /// url с обложкой фильма в высоком разрешении
    var resizedImageURL: URL {
           // создаем строку из адреса
           let urlString = imageURL.absoluteString
           //  обрезаем лишнюю часть и добавляем модификатор желаемого качества
           let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
           
           // пытаемся создать новый адрес, если не получается возвращаем старый
           guard let newURL = URL(string: imageUrlString) else {
               return imageURL
           }
           
           return newURL
       }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MostPopularMoviesCodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        do {
            let rating = try container.decode(String.self, forKey: .rating)
            if let ratingValue = Double(rating) {
                self.rating = ratingValue
            } else {
                self.rating = 0
            }
        } catch {
            self.rating = 0
        }
        imageURL = try container.decode(URL.self, forKey: .imageURL)
    }
    
    init(title: String, rating: Double, imageURL: URL) {
        self.title = title
        self.rating = rating
        self.imageURL = imageURL
    }
}

/// Структура для хранения json-структуры с фильмами
struct MostPopularMovies: Codable {
    /// Сообщение об ошибке
    var errorMessage: String
    /// Массив с информацией о фильмах
    var items: [MostPopularMovie]
    
    init(errorMessage: String, items: [MostPopularMovie]) {
        self.errorMessage = errorMessage
        self.items = items
    }
    
    func convertToCache() -> MostPopularMoviesCache {
        var movies = MostPopularMoviesCache(errorMessage: errorMessage, items: [])
        
        for movie in items {
            movies.items.append(MostPopularMovieCache(title: movie.title, rating: movie.rating, imageURL: movie.imageURL))
        }
        
        return(movies)
    }
}

struct MostPopularMovieCache: Codable {
    let title: String
    let rating: Double
    let imageURL: URL
}

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

enum MostPopularMoviesCodingKeys: String, CodingKey {
    case title = "fullTitle"
    case rating = "imDbRating"
    case imageURL = "image"
}

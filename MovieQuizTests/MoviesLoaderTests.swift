//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Сергей Кухарев on 14.04.2024.
//

import Foundation
import XCTest
@testable import MovieQuiz

struct StubMoviesLoader: MoviesLoadingProtocol {
    enum TestError: Error { // тестовая ошибка
    case test
    }

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

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
        // Given
        let loader = StubMoviesLoader(emulateError: false)

        // When
        let expecation = expectation(description: "Loading expectation")

        loader.loadMovies {result in
            // Then
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expecation.fulfill()
            case .failure:
                XCTFail("Unexpected failure")
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testFailureLoading() throws {
        // Given
        let loader = StubMoviesLoader(emulateError: true)

        // When
        let expecation = expectation(description: "Loading expectation")

        // Then
        loader.loadMovies {result in
            // Then
            switch result {
            case .success:
                XCTFail("Unexpected failure")
            case .failure(let error):
                XCTAssertNotNil(error)
                expecation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
}

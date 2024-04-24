//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Сергей Кухарев on 14.04.2024.
//

import Foundation
import XCTest
@testable import MovieQuiz

final class MoviesLoaderTests: XCTestCase {
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

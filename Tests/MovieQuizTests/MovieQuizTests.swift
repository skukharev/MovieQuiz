//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Сергей Кухарев on 14.04.2024.
//

import XCTest

@testable import MovieQuiz

final class MovieQuizTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddition() throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()

        // When
        let result = arithmeticOperations.addition(num1: 1, num2: 2)

        // Then
        XCTAssertEqual(result, 3)
    }

    func testAdditionAsync() throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()

        // When
        let expectation = expectation(description: "Addition function expectation")

        arithmeticOperations.additionAsync(num1: 1, num2: 2) {result in
            // Then
            XCTAssertEqual(result, 3)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
}

//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Сергей Кухарев on 14.04.2024.
//

import XCTest

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int) -> Int {
        return num1 + num2
    }

    func subtraction(num1: Int, num2: Int) -> Int {
        return num1 - num2
    }

    func multiplication(num1: Int, num2: Int) -> Int {
        return num1 * num2
    }

    func additionAsync(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   handler(num1 + num2)
               }
    }

    func subtractionAsync(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
               handler(num1 - num2)
           }
    }

    func multiplicationAsync(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                handler(num1 * num2)
            }
    }
}

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
        let num1 = 1
        let num2 = 2

        // When
        let result = arithmeticOperations.addition(num1: num1, num2: num2)

        // Then
        XCTAssertEqual(result, 3)
    }

    func testAdditionAsync() throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2

        // When
        let expectation = expectation(description: "Addition function expectation")

        arithmeticOperations.additionAsync(num1: num1, num2: num2) {result in
            // Then
            XCTAssertEqual(result, 3)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
}

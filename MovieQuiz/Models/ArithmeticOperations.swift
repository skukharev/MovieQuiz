//
//  ArithmeticOperations.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 24.04.2024.
//

import Foundation

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

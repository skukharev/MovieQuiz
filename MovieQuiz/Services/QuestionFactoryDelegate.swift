//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 17.03.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)   
}

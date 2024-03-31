//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 16.03.2024.
//

import Foundation

/// Протокол фабрики загрузки вопросов квиза
protocol QuestionFactoryProtocol {
    /// Функция формирует вопрос квиза из массива скачанных вопросов
    func requestNextQuestion()
    /// Функция скачивает массив вопросов из базы данных IMDB
    func loadData()
}

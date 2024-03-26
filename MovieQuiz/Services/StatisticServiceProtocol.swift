//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 26.03.2024.
//

import Foundation


/// Протокол для класса хранения статистики
protocol StatisticServiceProtocol {
    /// Средняя точность
    var totalAccuracy: Double { get }
    /// Количество завершённых игр
    var gamesCount: Int { get }
    /// Информация о лучшей попытке - количестве правильных ответов из общего количества заданных вопросов и дата/время рекорда
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}

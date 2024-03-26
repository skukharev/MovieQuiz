//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 17.03.2024.
//

import Foundation

/// Протокол взаимодействия с алертом
protocol AlertPresenterProtocol {
    /// Отображает результаты квиза
    /// - Parameter alert: Модель с данными результатов квиза
    func showAlert(alert: AlertModel)
}

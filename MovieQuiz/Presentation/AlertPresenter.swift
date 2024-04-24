//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 17.03.2024.
//

import Foundation
import UIKit

/// Класс для отображения результатов квиза
final class AlertPresenter: AlertPresenterProtocol {
    weak var view: UIViewController?
    init(view: UIViewController? = nil) {
        self.view = view
    }
    /// Отображает результаты квиза
    /// - Parameter alert: Структура для состояния "Результат квиза"
    func showAlert(alert: AlertModel) {
        guard let view = view else {
            return
        }
        let alertView = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: alert.buttonText, style: .default, handler: alert.completion))
        view.present(alertView, animated: true)
    }
}

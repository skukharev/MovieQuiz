//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 17.03.2024.
//

import Foundation
import UIKit

/// Структура для состояния "Результат квиза"
struct AlertModel {
    // текст заголовка алерта
    let title: String
    // текст сообщения алерта
    let message: String
    // текст для кнопки алерта
    let buttonText: String
    // замыкание без параметров для действия по кнопке алерта
    let completion: ((UIAlertAction) -> Void)?
}

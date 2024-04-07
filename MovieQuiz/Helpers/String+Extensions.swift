//
//  String+Extensions.swift
//
//  Created by Сергей Кухарев on 06.04.2024.
//

import Foundation

extension String: LocalizedError {
    /// Позволяет генерировать исключения в виде вызова throw "Текст ошибки"
    public var errorDescription: String? {
        return self
    }
}

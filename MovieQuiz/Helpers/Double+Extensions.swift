//
//  Double+Extensions.swift
//
//  Created by Сергей Кухарев on 08.03.2024.
//

import Foundation

extension Double {

    /// Конвертирует число в строку в формате процента с заданным количеством символов после разделителя дробной части
    /// - Parameter fractionalLength: Количество символов после разделителя дробной части
    /// - Returns: Возвращает строку
    func percentToString(fractionalLength: Int) -> String {
        let defaultFormatter: NumberFormatter = NumberFormatter.defaultPercent
        defaultFormatter.minimumFractionDigits = fractionalLength
        defaultFormatter.maximumFractionDigits = fractionalLength
        return defaultFormatter.string(from: (self as NSNumber))!
    }
}

private extension NumberFormatter {
    static let defaultPercent: NumberFormatter = {
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.locale = Locale.current
        return percentFormatter
    }()
}

//
//  Date+Extensions.swift
//  Counter
//
//  Created by Сергей Кухарев on 25.02.2024.
//

import Foundation

extension Date {
    /// Конвертирует дату/время  в строку в принятомм в РФ формате "ДД.ММ.ГГГГ ЧЧ24:ММ:СС"
    var dateTimeString: String { DateFormatter.defaultDateTime.string(from: self) }
}

private extension DateFormatter {
    static let defaultDateTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY hh:mm:ss"
        return dateFormatter
    }()
}

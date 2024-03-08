//
//  Double+Extensions.swift
//
//  Created by Сергей Кухарев on 08.03.2024.
//

import Foundation;

extension Double {

    //Возвращает строку с заданным количеством разрядов после запятой для процентных значений
    func percentToString(fractionalLength: Int) -> String {
        let defaultFormatter: NumberFormatter = NumberFormatter.defaultPercent;
        defaultFormatter.minimumFractionDigits = fractionalLength;
        defaultFormatter.maximumFractionDigits = fractionalLength;
        return defaultFormatter.string(from: (self as NSNumber))!;
    }
}

private extension NumberFormatter {
    static let defaultPercent: NumberFormatter = {
        let percentFormatter = NumberFormatter();
        percentFormatter.numberStyle = .percent;
        percentFormatter.locale = Locale.current;
        return percentFormatter;
    } ();
}

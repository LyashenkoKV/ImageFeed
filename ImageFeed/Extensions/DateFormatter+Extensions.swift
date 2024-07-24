//
//  DateFormatter+Extensions.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 16.07.2024.
//

import Foundation

extension DateFormatter {
    static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}

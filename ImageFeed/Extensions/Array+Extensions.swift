//
//  Array+Extensions.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 16.07.2024.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}

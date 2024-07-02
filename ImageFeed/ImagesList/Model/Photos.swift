//
//  Photo.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 27.06.2024.
//

import Foundation

struct Photos {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let regularImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

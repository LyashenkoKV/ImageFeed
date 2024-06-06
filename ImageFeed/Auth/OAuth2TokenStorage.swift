//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 05.06.2024.
//

import Foundation

// MARK: - UserDefaults
final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()

    private var tokenKey = "OAuth2Token"

    private init() {}

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}

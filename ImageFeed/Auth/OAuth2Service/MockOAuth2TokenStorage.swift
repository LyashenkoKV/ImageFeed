//
//  MockOAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 22.07.2024.
//
import Foundation

final class MockOAuth2TokenStorage: OAuth2TokenStorageProtocol {
    var token: String? = "mockToken"
}

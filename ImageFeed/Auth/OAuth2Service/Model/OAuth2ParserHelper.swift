//
//  OAuth2ParserHelper.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 18.07.2024.
//

import Foundation

// MARK: - Protocol
protocol OAuth2ParserHelperProtocol {
    func parse(data: Data) -> OAuthTokenResponseBody?
}

// MARK: - Object
final class OAuth2ParserHelper: OAuth2ParserHelperProtocol {
    func parse(data: Data) -> OAuthTokenResponseBody? {
        do {
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            OAuth2Service.shared.oAuth2TokenStorage.token = tokenResponse.accessToken
            Logger.shared.log(.debug,
                              message: "OAuth2ParserHelper: Access token сохранен",
                              metadata: ["✅": tokenResponse.accessToken])
            return tokenResponse
        } catch {
            let errorMessage = NetworkErrorHandler.errorMessage(from: error)
            Logger.shared.log(.error,
                              message: "OAuth2ParserHelper: Ошибка обработки токена:",
                              metadata: ["❌": errorMessage])
            return nil
        }
    }
}


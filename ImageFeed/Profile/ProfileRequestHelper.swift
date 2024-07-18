//
//  ProfileRequestHelper.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 18.07.2024.
//

import Foundation

final class RequestHelper {
    static func createRequest(urlString: String, method: String, token: String) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            Logger.shared.log(.error,
                              message: "RequestHelper: Неверная строка URL",
                              metadata: ["❌": urlString])
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        Logger.shared.log(.debug,
                          message: "RequestHelper: Запрос создан",
                          metadata: ["✅": "\(request)"])

        return request
    }
}

//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 19.07.2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURLString
    case unableToConstructURL
    case noInternetConnection
    case requestTimedOut
    case emptyData
    case tooManyRequests
    case unknownError
    case serviceUnavailable
    case errorFetchingAccessToken
    case unauthorized
    case notFound
}

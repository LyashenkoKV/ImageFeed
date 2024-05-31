//
//  Constants.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 30.05.2024.
//

import Foundation

enum Constants {
    static let accessKey = "YDB9YmrpeX5TFK7woqynOGi5hBWLuoBG8bJ9kxaOLb8"
    static let secretKey = "oEgPi3ZUXExKMhNxwpw0eAKRWBCyfRjh17NuYONkMEs"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")!
}

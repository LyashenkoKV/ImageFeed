//
//  File.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 31.05.2024.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

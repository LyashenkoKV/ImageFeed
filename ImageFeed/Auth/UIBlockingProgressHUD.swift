//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 14.06.2024.
//

import ProgressHUD
import UIKit
// MARK: - protocol
protocol UIBlockingProgressHUDProtocol {
    static func show()
    static func dismiss()
}
// MARK: - object
final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.windows.first
        }
    }
}
// MARK: - UIBlockingProgressHUDProtocol
extension UIBlockingProgressHUD: UIBlockingProgressHUDProtocol {
    static func show() {
            guard let window = window else {
                Logger.shared.log(.error,
                                  message: "UIBlockingProgressHUD: window недоступно",
                                  metadata: ["❌": ""])
                return
            }
            
            window.isUserInteractionEnabled = false
            ProgressHUD.animate()
        }
        
        static func dismiss() {
            guard let window = window else {
                Logger.shared.log(.error,
                                  message: "UIBlockingProgressHUD: window недоступно",
                                  metadata: ["❌": ""])
                return
            }
            
            window.isUserInteractionEnabled = true
            ProgressHUD.dismiss()
        }
}

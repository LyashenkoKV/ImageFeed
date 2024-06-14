//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 14.06.2024.
//

import ProgressHUD
import UIKit

protocol UIBlockingProgressHUDProtocol {
    static func show()
    static func dismiss()
}

final class UIBlockingProgressHUD: UIBlockingProgressHUDProtocol {
    private static var window: UIWindow? {
        if #available(iOS 15.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return nil
            }
            return windowScene.windows.first
        } else {
            return UIApplication.shared.windows.first
        }
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
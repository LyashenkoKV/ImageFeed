//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 17.06.2024.
//

import UIKit

struct AlertModel {
    enum Context {
        case back, error, logout
    }
    
    let title: String
    let message: String
    let buttons: [AlertButton]
    let context: Context
}

struct AlertButton {
    let title: String
    let style: UIAlertAction.Style
    let identifier: String?
    let handler: (() -> Void)?
}

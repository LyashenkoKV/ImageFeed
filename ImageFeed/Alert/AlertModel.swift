//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 17.06.2024.
//

import Foundation

struct AlertModel {
    enum Context {
        case back, error
    }
    
    let title: String
    let message: String
    let buttonText: String
    let context: Context
    let completion: (()->Void)?
}

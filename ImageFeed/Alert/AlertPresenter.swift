//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 17.06.2024.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(_ alert: UIAlertController)
}

final class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert(with model: AlertModel, identifier: String? = nil) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) {_ in
            model.completion?()
        }
        alert.addAction(action)
        
        switch model.context {
        case .back:
            alert.view.accessibilityIdentifier = "Back"
        case .error:
            alert.view.accessibilityIdentifier = "ErrorAlert"
        }
        delegate?.presentAlert(alert)
    }
}

//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 16.07.2024.
//

import UIKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func exitButtonPressed()
    func updateProfileImage(with url: String)
}

final class ProfilePresenter: ProfilePresenterProtocol {
   
    weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var alertPresenter = AlertPresenter()
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        view?.showLoading()
        addObserver()
        tryShowProfileDetails()
    }
    
    func exitButtonPressed() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttons: [
                AlertButton(title: "Нет", style: .default, handler: nil),
                AlertButton(title: "Да", style: .cancel, handler: {
                    ProfileLogoutService.shared.logout()
                })
            ],
            context: .back
        )
        AlertPresenter.showAlert(with: alertModel, delegate: view as? AlertPresenterDelegate)
    }
    
    private func tryShowProfileDetails() {
        let profileService = ProfileService.shared
        if let profile = profileService.profile {
            view?.hideLoading()
            view?.showProfileDetails(profile: profile)
        } else {
            view?.showLoading()
        }
    }
    
    func updateProfileImage(with url: String) {
        guard let url = URL(string: url) else { return }
        
        view?.showLoading()
        
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(systemName: "person.crop.circle.fill"),
                              options: [.transition(.fade(0.2))]) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                self.view?.updateProfileImage(with: value.image)
                self.view?.hideLoading()
            case .failure(let error):
                let errorMessage = NetworkErrorHandler.errorMessage(from: error)
                Logger.shared.log(.error,
                                  message: "ProfilePresenter: Не удалось загрузить Image",
                                  metadata: ["❌": errorMessage])
                self.view?.hideLoading()
            }
        }
    }
    
    private func addObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification,
                                                                             object: nil,
                                                                             queue: .main,
                                                                             using: { [weak self] notification in
            guard let self else { return }
            
            if let userInfo = notification.userInfo, let profileImageURL = userInfo["URL"] as? String {
                updateProfileImage(with: profileImageURL)
            }
        })
        
        if let profileImageURL = ProfileImageService.shared.avatarURL {
            updateProfileImage(with: profileImageURL)
        }
    }
}


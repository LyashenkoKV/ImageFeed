//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 16.05.2024.
//

import UIKit
import SkeletonView
import Kingfisher

// MARK: - Object
final class ProfileViewController: UIViewController {
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .ypGray
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isSkeletonable = true
        imageView.skeletonCornerRadius = 35
        return imageView
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        button.tintColor = .ypRed
        button.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isSkeletonable = true
        label.skeletonCornerRadius = 15
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isSkeletonable = true
        label.skeletonCornerRadius = 15
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isSkeletonable = true
        label.skeletonCornerRadius = 15
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupUI()
        setupConstraints()
        addObserver()
        tryShowProfileDetails()
    }
    
    private func setupUI() {
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(exitButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)
        ])
    }
}

// MARK: - Button Action
private extension ProfileViewController {
    @objc private func exitButtonPressed() {
        //TODO: process code
        let keychainService = KeychainService.shared // ❌
        let tokenKey = "OAuth2Token" // ❌
        _ = keychainService.delete(valueFor: tokenKey) // ❌
    }
}

// MARK: - Update Profile Details
private extension ProfileViewController {
    
    private func tryShowProfileDetails() {
        let profileService = ProfileService.shared
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
            hideProfileSkeletons()
        } else {
            showSkeletonsProfile()
        }
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
}


// MARK: - Load Image & Observer
private extension ProfileViewController {
    private func addObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification,
                                                                             object: nil,
                                                                             queue: .main,
                                                                             using: { [weak self] notification in
            guard let self else { return }
            
            if let userInfo = notification.userInfo, let profileImageURL = userInfo["URL"] as? String {
                self.loadImage(from: profileImageURL)
            } else {
                self.showSkeletonsImage()
            }
        })
        if let profileImageURL = ProfileImageService.shared.avatarURL {
            loadImage(from: profileImageURL)
        } else {
            showSkeletonsImage()
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(with: url,
                                 placeholder: UIImage(systemName: "person.crop.circle.fill"),
                                 options: [.transition(.fade(0.2))]) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                self.hideImageSkeleton()
            case .failure(let error):
                print("Не удалось загрузить Image: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - SkeletonView
private extension ProfileViewController {
    
    private func showSkeletonsProfile() {
        DispatchQueue.main.async {
            self.profileImage.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .darkGray))
            self.nameLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .darkGray))
            self.loginNameLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .darkGray))
            self.descriptionLabel.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .darkGray))
        }
    }
    
    private func showSkeletonsImage() {
        DispatchQueue.main.async {
            self.profileImage.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .darkGray))
        }
    }

    private func hideProfileSkeletons() {
        nameLabel.hideSkeleton()
        loginNameLabel.hideSkeleton()
        descriptionLabel.hideSkeleton()
        
        nameLabel.isSkeletonable = false
        loginNameLabel.isSkeletonable = false
        descriptionLabel.isSkeletonable = false
    }
    
    private func hideImageSkeleton() {
        profileImage.hideSkeleton()
        profileImage.isSkeletonable = false
    }
}

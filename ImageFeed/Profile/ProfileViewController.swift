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
    
    private lazy var profileLoadingView = ProfileLoadingView()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .ypGray
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        button.tintColor = .ypRed
        button.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = UIFont.boldSystemFont(ofSize: 23)
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileImage, exitButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [horizontalStackView, nameLabel, loginNameLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
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
        view.addSubview(profileLoadingView)
        profileLoadingView.frame = view.bounds
        profileLoadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        profileLoadingView.startAnimating()
    }
    
    private func setupConstraints() {
        [profileImage, exitButton, nameLabel, loginNameLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        profileLoadingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(verticalStackView)
        view.addSubview(profileLoadingView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            verticalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            exitButton.widthAnchor.constraint(equalToConstant: 42),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor),
            
            profileLoadingView.topAnchor.constraint(equalTo: view.topAnchor),
            profileLoadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileLoadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileLoadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        profileImage.layer.cornerRadius = 35
        profileImage.layer.masksToBounds = true
    }
}

// MARK: - Button Action
private extension ProfileViewController {
    @objc private func exitButtonPressed() {
        ProfileLogoutService.shared.logout()
    }
}

// MARK: - Update Profile Details
private extension ProfileViewController {
    
    private func tryShowProfileDetails() {
        let profileService = ProfileService.shared
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
            profileLoadingView.removeFromSuperview()
        } else {
            profileLoadingView.startAnimating()
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
            }
        })
        if let profileImageURL = ProfileImageService.shared.avatarURL {
            loadImage(from: profileImageURL)
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
                self.profileLoadingView.removeFromSuperview()
            case .failure(let error):
                print("Не удалось загрузить Image: \(error.localizedDescription)")
            }
        }
    }
}

//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 16.05.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let profileImage = UIImageView()
    private let exitButton = UIButton()
    private let nameLabel = UILabel()
    private let mailLabel = UILabel()
    private let descriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        profileImage.image = UIImage(systemName: "person.crop.circle.fill")
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        configureProfileImage()
        configureExitButton()
        configureNameLabel()
        configureMailLabel()
        configureDescriptionLabel()
        setupStackViews()
    }
    
    private func configureProfileImage() {
        profileImage.contentMode = .scaleAspectFit
        profileImage.image = UIImage(named: "Photo")
        profileImage.layer.cornerRadius = 25
        profileImage.clipsToBounds = true
    }
    
    private func configureExitButton() {
        exitButton.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        exitButton.tintColor = .ypRed
        exitButton.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)
    }

    private func configureNameLabel() {
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.text = "Екатерина Новикова"
    }
    
    private func configureMailLabel() {
        mailLabel.textColor = .ypGray
        mailLabel.font = UIFont.systemFont(ofSize: 13)
        mailLabel.text = "@ekaterina_nov"
    }
    
    private func configureDescriptionLabel() {
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Hello, world!"
    }
    
    private func setupStackViews() {
        let horizontalStackView = UIStackView(arrangedSubviews: [profileImage, exitButton])
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .equalSpacing

        let verticalStackView = UIStackView(arrangedSubviews: [horizontalStackView, nameLabel, mailLabel, descriptionLabel])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10

        view.addSubview(verticalStackView)
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        guard let verticalStackView = view.subviews.first(where: { $0 is UIStackView }) else { return }
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            verticalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            exitButton.widthAnchor.constraint(equalToConstant: 42),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor)
        ])
    }
    
    @objc func exitButtonPressed() {}
}

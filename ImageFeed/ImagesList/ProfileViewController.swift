//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 16.05.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let verticalStackView = UIStackView()
    private let horizontalStackView = UIStackView()
    private let profileImage = UIImageView()
    private let exitButton = UIButton()
    private let nameLabel = UILabel()
    private let mailLabel = UILabel()
    private let descriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        configureSubviews()
        addSubviews()
        addConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(profileImage)
        horizontalStackView.addArrangedSubview(exitButton)
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(mailLabel)
        verticalStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func configureSubviews() {
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 10
        horizontalStackView.distribution = .equalSpacing
        
        profileImage.contentMode = .scaleAspectFit
        profileImage.image = UIImage(named: "Photo")
        profileImage.layer.cornerRadius = 35
        profileImage.clipsToBounds = true
        
        exitButton.setImage(UIImage(named: "Exit"), for: .normal)
        exitButton.tintColor = .ypWhite.withAlphaComponent(0.5)
        exitButton.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)

        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.text = "Екатерина Новикова"
        
        mailLabel.textColor = .ypGray
        mailLabel.font = UIFont.systemFont(ofSize: 13)
        mailLabel.text = "@ekaterina_nov"
        
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Hello, world!"
    }
    
    private func addConstraints() {
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            exitButton.widthAnchor.constraint(equalToConstant: 42),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor)
        ])
    }
    
    @objc func exitButtonPressed() {
        
    }
}

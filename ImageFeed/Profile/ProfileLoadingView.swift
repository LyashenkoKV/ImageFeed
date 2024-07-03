//
//  ProfileLoadingView.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 03.07.2024.
//

import UIKit
import SkeletonView

final class ProfileLoadingView: UIView {
    
    private lazy var profileImage = buildAnimatedViews()
    private lazy var nameLabel = buildAnimatedViews()
    private lazy var loginNameLabel = buildAnimatedViews()
    private lazy var descriptionLabel = buildAnimatedViews()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        button.tintColor = .ypRed
        return button
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileImage,
                                                       exitButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.isSkeletonable = true
        return stackView
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [horizontalStackView, 
                                                       nameLabel,
                                                       loginNameLabel,
                                                       descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isSkeletonable = true
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .ypBlack
        setupConstraints()
        startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        addSubview(verticalStackView)
        [profileImage, 
         nameLabel,
         loginNameLabel,
         descriptionLabel,
         exitButton,
         horizontalStackView,
         verticalStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            verticalStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            verticalStackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            exitButton.widthAnchor.constraint(equalToConstant: 42),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor),
            
            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            loginNameLabel.heightAnchor.constraint(equalToConstant: 20),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        profileImage.layer.cornerRadius = 35
        nameLabel.layer.cornerRadius = 10
        loginNameLabel.layer.cornerRadius = 10
        descriptionLabel.layer.cornerRadius = 10
        
        profileImage.layer.masksToBounds = true
        nameLabel.layer.masksToBounds = true
        loginNameLabel.layer.masksToBounds = true
        descriptionLabel.layer.masksToBounds = true
    }
    
    func startAnimating() {
        verticalStackView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .darkGray))
        horizontalStackView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .darkGray))
        
        [profileImage, nameLabel, loginNameLabel, descriptionLabel].forEach {
            $0.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .darkGray))
        }
    }
    
    private func buildAnimatedViews() -> UIView {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.isSkeletonable = true
        return view
    }
}

//
//  ImageTableViewCell.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 07.05.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    private let customContentView = UIView()
    private let likeButton = UIButton(type: .custom)

    let image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .ypBlack
        return imageView
    }()
    
    let customTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
    
    private func addGradientView() {
        let gradientView = UIView(frame: CGRect(x: 0.0, y: customContentView.frame.height - 30.0, width: image.bounds.width, height: 30.0))
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.ypBlack.withAlphaComponent(0.2).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
        customContentView.addSubview(gradientView)
    }
    
    private func configureSubviews() {
        customContentView.translatesAutoresizingMaskIntoConstraints = false
        customContentView.backgroundColor = .ypBlack
        customContentView.layer.cornerRadius = 16
        customContentView.clipsToBounds = true
        
        if let heartImage = UIImage(systemName: "heart.fill") {
            let resizedHeartImage = heartImage.resizableImage(withCapInsets: .zero)
            
            likeButton.setImage(resizedHeartImage, for: .normal)
            likeButton.tintColor = .gray
            likeButton.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
            likeButton.translatesAutoresizingMaskIntoConstraints = false
        }
        
        customContentView.addSubview(image)
        customContentView.addSubview(likeButton)
        customContentView.addSubview(customTextLabel)
        contentView.addSubview(customContentView)

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: customContentView.topAnchor),
            image.bottomAnchor.constraint(equalTo: customContentView.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: customContentView.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor),
            
            customTextLabel.heightAnchor.constraint(equalToConstant: 18),
            customTextLabel.bottomAnchor.constraint(equalTo: customContentView.bottomAnchor, constant: -8),
            customTextLabel.leadingAnchor.constraint(equalTo: customContentView.leadingAnchor, constant: 8),
            customTextLabel.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor),
            
            customContentView.topAnchor.constraint(equalTo: topAnchor),
            customContentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            customContentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            customContentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            likeButton.topAnchor.constraint(equalTo: customContentView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 42),
            likeButton.heightAnchor.constraint(equalToConstant: 42),
        ])
        addGradientView()
    }
    
    @objc func likeButtonPressed() {
        likeButton.tintColor = likeButton.tintColor == .red ? .gray : .red
    }
}
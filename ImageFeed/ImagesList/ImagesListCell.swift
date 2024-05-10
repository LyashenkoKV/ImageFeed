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
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
    
    private func custGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.frame = image.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0 as NSNumber, 0 as NSNumber, 0.9 as NSNumber, 1 as NSNumber]
        image.layer.mask = gradient
    }
    
    private func configureSubviews() {
        customContentView.translatesAutoresizingMaskIntoConstraints = false
        customContentView.backgroundColor = .ypBlack
        customContentView.layer.cornerRadius = 16
        customContentView.clipsToBounds = true
        
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        likeButton.tintColor = .gray
        likeButton.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        customContentView.addSubview(image)
        customContentView.addSubview(likeButton)
        customContentView.addSubview(customTextLabel)
        contentView.addSubview(customContentView)

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: customContentView.topAnchor),
            image.bottomAnchor.constraint(equalTo: customContentView.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: customContentView.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor),
            
            customTextLabel.heightAnchor.constraint(equalToConstant: 20),
            customTextLabel.bottomAnchor.constraint(equalTo: customContentView.bottomAnchor, constant: -16),
            customTextLabel.leadingAnchor.constraint(equalTo: customContentView.leadingAnchor, constant: 16),
            customTextLabel.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor, constant: -16),
            
            customContentView.topAnchor.constraint(equalTo: topAnchor),
            customContentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            customContentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            customContentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            likeButton.topAnchor.constraint(equalTo: customContentView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        custGradientLayer()
    }
    
    @objc func likeButtonPressed() {
        likeButton.tintColor = likeButton.tintColor == .red ? .gray : .red
    }
}

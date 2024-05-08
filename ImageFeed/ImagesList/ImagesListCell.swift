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
    private let gradientLayer = CAGradientLayer()
    private let likeButton = UIButton(type: .custom)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    }
    
    func configureSubviews() {
        customContentView.translatesAutoresizingMaskIntoConstraints = false
        customContentView.backgroundColor = .ypBlack
        customContentView.layer.cornerRadius = 16
        customContentView.clipsToBounds = true
        
        let gradientHeight = 30.0
        let cornerRadius = customContentView.layer.cornerRadius
        let bottomPadding = 8.0
        gradientLayer.frame = CGRect(
            x: 0,
            y: customContentView.frame.height - gradientHeight - bottomPadding - cornerRadius,
            width: customContentView.bounds.width,
            height: gradientHeight
        )
        
        likeButton.setImage(UIImage(named: "like"), for: .normal)
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
            
            customTextLabel.bottomAnchor.constraint(equalTo: customContentView.bottomAnchor, constant: -16),
            customTextLabel.leadingAnchor.constraint(equalTo: customContentView.leadingAnchor, constant: 16),
            customTextLabel.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor, constant: -16),
            
            customContentView.topAnchor.constraint(equalTo: topAnchor),
            customContentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            customContentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            customContentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            likeButton.topAnchor.constraint(equalTo: customContentView.topAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: customContentView.trailingAnchor, constant: -8),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc func likeButtonPressed() {
        print("Like button pressed!")
    }
}

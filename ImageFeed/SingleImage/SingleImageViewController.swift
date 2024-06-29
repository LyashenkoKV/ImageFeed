//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 20.05.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        scrollView.backgroundColor = .ypBlack
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .ypBlack
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 25
        button.backgroundColor = .ypBlack
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        setupViews()
        rescaleAndCenterImageInScrollView()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            
            shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 17)
        ])
    }
    
    private func rescaleAndCenterImageInScrollView() {
        guard let image = imageView.image else { return }
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        centerImage()
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        let horizontalPadding = max(0, (scrollViewSize.width - imageSize.width) / 2)
        let verticalPadding = max(0, (scrollViewSize.height - imageSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding,
                                               left: horizontalPadding,
                                               bottom: verticalPadding,
                                               right: horizontalPadding)
    }
}

// MARK: - Button Action
private extension SingleImageViewController {
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Configure Image
extension SingleImageViewController {
    func configure(withImageURL imageURL: URL) {
        imageView.kf.setImage(with: imageURL,
                              placeholder: UIImage(named: "Stub"),
                              options: [
                                .transition(.fade(0.1)),
                                .cacheOriginalImage]) { [weak self] result in
                                    guard let self else { return }
                                    
                                    switch result {
                                    case .success(let value):
                                        self.imageView.image = value.image
                                        self.imageView.frame.size = value.image.size
                                        self.rescaleAndCenterImageInScrollView()
                                    case .failure(let error):
                                        let errorMessage = NetworkErrorHandler.errorMessage(from: error)
                                        print("Ошибка загрузки изображения: \(errorMessage)")
                                    }
                                }
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

// MARK: - Share
extension SingleImageViewController {
    @objc private func shareButtonTapped() {
        guard let image = imageView.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.completionWithItemsHandler = { _, success, _, error in
            if let error = error {
                Logger.shared.log(.error,
                                  message: "ImagesListService: Не удалось расшарить изображения",
                                  metadata: ["❌": error.localizedDescription])
            } else if success {
                Logger.shared.log(.debug,
                                  message: "SingleImageViewController: Изображения успешно расшарено",
                                  metadata: ["✅": ""])
            } else {
                Logger.shared.log(.debug,
                                  message: "SingleImageViewController: Sharing отменен",
                                  metadata: ["✅": ""])
            }
        }
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

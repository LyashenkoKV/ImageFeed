//
//  ViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 06.05.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    private let storage = OAuth2TokenStorage.shared
    private let imagesListService = ImagesListService.shared
    private let refreshControl = UIRefreshControl()
    
    private lazy var stubImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "Stub"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        if let tabBarItem = self.tabBarItem {
            let imageInset = UIEdgeInsets(top: 13, left: 0, bottom: -13, right: 0)
            tabBarItem.imageInsets = imageInset
        }
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        configureTableView()
        configureStubImageView()
        setupNotifications()
        fetchPhotos()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.addSubview(refreshControl)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureStubImageView() {
        view.addSubview(stubImageView)
        
        NSLayoutConstraint.activate([
            stubImageView.widthAnchor.constraint(equalToConstant: 83),
            stubImageView.heightAnchor.constraint(equalToConstant: 75),
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func refreshTableView() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}

// MARK: - Observer
private extension ImagesListViewController {
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleImagesListServiceDidChangeNotification(_:)),
                                               name: ImagesListService.didChangeNotification,
                                               object: nil)
    }
    
    @objc private func handleImagesListServiceDidChangeNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let startIndex = userInfo["startIndex"] as? Int,
              let endIndex = userInfo["endIndex"] as? Int else {
            tableView.reloadData()
            stubImageView.isHidden = !imagesListService.photos.isEmpty
            return
        }
        let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

        UIView.performWithoutAnimation {
            tableView.performBatchUpdates({
                tableView.insertRows(at: indexPaths, with: .none)
            }, completion: { _ in
                self.stubImageView.isHidden = !self.imagesListService.photos.isEmpty
            })
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        configCell(cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = imagesListService.photos[indexPath.row]
        
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - insets.left - insets.right
        let imageWidth = CGFloat(photo.size.width)
        let scale = imageViewWidth / imageWidth
        let cellHeight = CGFloat(photo.size.height) * scale + insets.top + insets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count - 1 {
            fetchPhotos()
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        
        let photo = imagesListService.photos[indexPath.row]
        guard let imageURL = URL(string: photo.largeImageURL) else { return }
        
        singleImageViewController.configure(withImageURL: imageURL)
        singleImageViewController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(singleImageViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Configure Images
extension ImagesListViewController {
    
    private func fetchPhotos() {
        if let token = storage.token {
            DispatchQueue.main.async {
                self.imagesListService.fetchPhotosNextPage(with: token)
            }
        }
    }
    
    private func configCell(_ cell: ImagesListCell, for indexPath: IndexPath) {
        cell.backgroundColor = .ypBlack
        cell.selectionStyle = .none
        
        var photo = imagesListService.photos[indexPath.row]
        let imageURL = URL(string: photo.regularImageURL)
        let dateText = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.configure(withImageURL: imageURL, text: dateText, isLiked: photo.isLiked, photoId: photo.id)
        
        cell.likeButtonAction = { [weak self] (photoId, shouldLike) in
            guard let self else { return }
            self.imagesListService.changeLike(photoId: photoId, isLike: shouldLike) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        photo.isLiked = shouldLike
                        cell.isLiked = shouldLike
                    }
                case .failure(let error):
                    _ = NetworkErrorHandler.errorMessage(from: error)
                }
            }
        }
    }
}

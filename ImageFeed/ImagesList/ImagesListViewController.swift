//
//  ViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 06.05.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    private let storage = OAuth2TokenStorage.shared
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let imagesListService = ImagesListService.shared
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .ypBlack
        
        if let tabBarItem = self.tabBarItem {
            let imageInset = UIEdgeInsets(top: 13, left: 0, bottom: -13, right: 0)
            tabBarItem.imageInsets = imageInset
        }
        
        configureTableView()
        setupNotifications()
        checkAuthorization()
    }
    
    private func checkAuthorization() {
        if let token = storage.token {
            DispatchQueue.main.async {
                self.imagesListService.fetchPhotosNextPage(with: token)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadData),
                                               name: ImagesListService.didChangeNotification,
                                               object: nil)
    }
    
    private func configCell(_ cell: ImagesListCell, for indexPath: IndexPath) {
        cell.backgroundColor = .ypBlack
        cell.selectionStyle = .none
        
        let photo = imagesListService.photos[indexPath.row]
        let imageURL = URL(string: photo.thumbImageURL)
        let dateText = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.configure(withImageURL: imageURL, text: dateText, isLiked: photo.isLiked)
    }
    
    @objc private func reloadData() {
        tableView.reloadData()
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
            checkAuthorization()
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

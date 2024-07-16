//
//  ViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 06.05.2024.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateImagesList(startIndex: Int, endIndex: Int)
    func reloadTableView()
    func showStubImageView(_ isHidden: Bool)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    private var presenter: ImagesListPresenterProtocol?
    
    private let refreshControl = UIRefreshControl()
    private let storage = OAuth2TokenStorage.shared
    private let imagesListService = ImagesListService.shared
    
    private lazy var stubImageView = UIImageView(image: UIImage(named: "Stub"))
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        presenter = ImagesListPresenter(view: self,
                                             imagesListService: imagesListService,
                                             storage: storage)
        
        if let tabBarItem = self.tabBarItem {
            let imageInset = UIEdgeInsets(top: 13, left: 0, bottom: -13, right: 0)
            tabBarItem.imageInsets = imageInset
        }
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        configureTableView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.fetchPhotos()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.addSubview(refreshControl)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }
    
    private func setupConstraints() {
        [tableView, stubImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stubImageView.widthAnchor.constraint(equalToConstant: 83),
            stubImageView.heightAnchor.constraint(equalToConstant: 75),
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func refreshTableView() {
        presenter?.fetchPhotos()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func updateImagesList(startIndex: Int, endIndex: Int) {
        let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }
        UIView.performWithoutAnimation { [weak self] in
            self?.tableView.performBatchUpdates({
                self?.tableView.insertRows(at: indexPaths, with: .none)
            })
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func showStubImageView(_ isHidden: Bool) {
        stubImageView.isHidden = isHidden
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numbersOfPhotos = presenter?.numberOfPhotos() else { return 0 }
        return numbersOfPhotos
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        if let photo = presenter?.photo(at: indexPath.row),
           let dateText = presenter?.format(date: photo.createdAt), let presenter = presenter as? ImagesListPresenter {
            cell.configure(with: photo, dateText: dateText, presenter: presenter)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath.row) else { return 0 }
        
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - insets.left - insets.right
        let imageWidth = CGFloat(photo.size.width)
        let scale = imageViewWidth / imageWidth
        let cellHeight = CGFloat(photo.size.height) * scale + insets.top + insets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let numbersOfPhotos = presenter?.numberOfPhotos() else { return }
        if indexPath.row == numbersOfPhotos - 1 {
            presenter?.fetchPhotos()
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        
        guard let photo = presenter?.photo(at: indexPath.row),
              let imageURL = URL(string: photo.largeImageURL) else { return }
        
        singleImageViewController.configure(withImageURL: imageURL)
        singleImageViewController.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(singleImageViewController, animated: true, completion: nil)
        }
    }
}

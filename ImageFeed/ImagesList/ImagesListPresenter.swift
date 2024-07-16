//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 16.07.2024.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func fetchPhotos()
    func numberOfPhotos() -> Int
    func photo(at index: Int) -> Photo?
    func format(date: Date?) -> String
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<VoidModel, Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private let storage: OAuth2TokenStorageProtocol
    private var dateFormatter: DateFormatter?
    
    init(view: ImagesListViewControllerProtocol,
         imagesListService: ImagesListServiceProtocol,
         storage: OAuth2TokenStorageProtocol) {
        self.view = view
        self.imagesListService = imagesListService
        self.storage = storage
        self.dateFormatter = DateFormatter.longDateFormatter
        
        setupNotifications()
    }
    
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
            
            view?.reloadTableView()
            view?.showStubImageView(!imagesListService.photos.isEmpty)
            return
        }
        view?.updateImagesList(startIndex: startIndex, endIndex: endIndex)
    }
    
    func fetchPhotos() {
        if let token = storage.token {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.imagesListService.fetchPhotosNextPage(with: token)
            }
        }
    }
    
    func numberOfPhotos() -> Int {
        return imagesListService.photos.count
    }
    
    func photo(at index: Int) -> Photo? {
        guard index < imagesListService.photos.count else { return nil }
        return imagesListService.photos[safe: index]
    }
    
    func format(date: Date?) -> String {
        guard let date = date, let formatDate = dateFormatter?.string(from: date) else { return "Дата неизвестна" }
        return formatDate
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<VoidModel, Error>) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLike: isLike, completion)
    }
}

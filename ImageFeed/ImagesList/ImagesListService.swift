//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 27.06.2024.
//

import Foundation
import Kingfisher

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let photosNetworkService = GenericNetworkService<[PhotoResult]>()
    private let likeNetworkService = GenericNetworkService<VoidModel>()
    
    private (set) var photos: [Photos] = []
    private var lastLoadedPage: Int?
    private var isLoading: Bool = false
    
    private let synchronizationQueue = DispatchQueue(label: "ImagesListService.serialQueue")
    private let semaphore = DispatchSemaphore(value: 1)
    
    private init() {
        loadLikes()
    }
    
    private func addPhotos(_ newPhotos: [Photos]) {
        let startIndex = photos.count
        photos.append(contentsOf: newPhotos)
        let endIndex = photos.count - 1
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                        object: nil,
                                        userInfo: ["startIndex": startIndex, "endIndex": endIndex])
    }
    
    func clearImagesList() {
        photos = []
        lastLoadedPage = nil
        Logger.shared.log(.debug,
                          message: "ImagesListService: Массив изображений пуст",
                          metadata: ["✅": ""])
    }
}

// MARK: - NetworkService for Likes
extension ImagesListService {
    
    private func saveLikes() {
        let likes = photos.map { [$0.id: $0.isLiked] }
        UserDefaults.standard.set(likes, forKey: "photoLikes")
    }
    
    private func loadLikes() {
        guard let likes = UserDefaults.standard.array(forKey: "photoLikes") as? [[String: Bool]] else { return }
        for like in likes {
            if let id = like.keys.first, let isLiked = like.values.first {
                if let index = photos.firstIndex(where: { $0.id == id }) {
                    photos[index].isLiked = isLiked
                }
            }
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<VoidModel, Error>) -> Void) {
        synchronizationQueue.async {
            self.semaphore.wait()
            defer { self.semaphore.signal() }
            
            let method = isLike ? "POST" : "DELETE"
            let url = "\(APIEndpoints.Photos.photos)/\(photoId)/like"
            
            guard let token = OAuth2TokenStorage.shared.token, !token.isEmpty else {
                completion(.failure(NetworkError.errorFetchingAccessToken))
                Logger.shared.log(.error,
                                  message: "ImagesListService: Токен доступа недоступен или пуст",
                                  metadata: ["❌": ""])
                return
            }
            
            self.likeNetworkService.fetch(parameters: ["token": token],
                                          method: method,
                                          url: url) { result in
                switch result {
                case .success(_):
                    if isLike {
                        Logger.shared.log(.debug,
                                          message: "ImagesListService: Лайк поставлен",
                                          metadata: ["✅": ""])
                    } else {
                        Logger.shared.log(.debug,
                                          message: "ImagesListService: Лайк снят",
                                          metadata: ["✅": ""])
                    }
                    
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        self.photos[index].isLiked = isLike
                        self.saveLikes()
                    }
                    
                    completion(.success(VoidModel()))
                case .failure(let error):
                    completion(.failure(error))
                    let errorMessage = NetworkErrorHandler.errorMessage(from: error)
                    Logger.shared.log(.error,
                                      message: "ImagesListService: Ошибка при изменении состояния лайка",
                                      metadata: ["❌": errorMessage])
                }
            }
        }
    }
}

// MARK: - NetworkService for Image
extension ImagesListService {
    
    func fetchPhotosNextPage(with token: String) {
        synchronizationQueue.async {
            self.semaphore.wait()
            defer { self.semaphore.signal() }
            
            guard !self.isLoading else { return }
            self.isLoading = true
            let nextPage = (self.lastLoadedPage ?? 0) + 1
            
            self.photosNetworkService.fetch(parameters: ["page": "\(nextPage)", "per_page": "10", "token": token],
                                            method: "GET",
                                            url: APIEndpoints.Photos.photos) { [weak self] (result) in
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.compactMap { self.mapToPhotos(photoResult: $0) }
                    self.lastLoadedPage = nextPage
                    self.addPhotos(newPhotos)
                    Logger.shared.log(.debug,
                                      message: "ImagesListService: Изображения успешно получены",
                                      metadata: ["✅": ""])
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                case .failure(let error):
                    let errorMessage = NetworkErrorHandler.errorMessage(from: error)
                    Logger.shared.log(.error,
                                      message: "ImagesListService: Не удалось получить изображения",
                                      metadata: ["❌": errorMessage])
                }
            }
        }
    }
}
// MARK: - Map to Photos
extension ImagesListService {
    
    private func mapToPhotos(photoResult: PhotoResult) -> Photos {
        let dateFormatter = ISO8601DateFormatter()
        let date = photoResult.createdAt.flatMap { dateFormatter.date(from: $0) }
        
        return Photos(id: photoResult.id,
                      size: CGSize(width: photoResult.width,
                                   height: photoResult.height),
                      createdAt: date,
                      welcomeDescription: photoResult.description,
                      regularImageURL: photoResult.urls.regular,
                      largeImageURL: photoResult.urls.full,
                      isLiked: photoResult.likedByUser)
    }
}

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
    
    private (set) var photos: [Photos] = []
    private var lastLoadedPage: Int?
    private var isLoading: Bool = false
    
    private let synchronizationQueue = DispatchQueue(label: "ImagesListService.serialQueue")
    private let semaphore = DispatchSemaphore(value: 1)
    
    private init() {}
    
    private func addPhotos(_ newPhotos: [Photos]) {
        let startIndex = photos.count
        photos.append(contentsOf: newPhotos)
        let endIndex = photos.count - 1
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil, userInfo: ["startIndex": startIndex, "endIndex": endIndex])
    }
}

// MARK: - NetworkService
extension ImagesListService: NetworkService {
    typealias Model = [PhotoResult]
    
    func makeRequest(parameters: [String : String], method: String, url: String) -> URLRequest? {
        var components = URLComponents(string: url)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let finalURl = components?.url else {
            Logger.shared.log(.error, 
                              message: "ImagesListService: Неверная строка URL",
                              metadata: ["❌": url])
            return nil
        }
        
        var request = URLRequest(url: finalURl)
        request.httpMethod = method
        request.setValue("Bearer \(parameters["token"] ?? "")",
                         forHTTPHeaderField: "Authorization")
        
        Logger.shared.log(.debug, 
                          message: "ImagesListService: Запрос создан:",
                          metadata: ["✅": "\(request)"])
        
        return request
    }
    
    func parse(data: Data) -> [PhotoResult]? {
        let decoder = JSONDecoder()
        return try? decoder.decode([PhotoResult].self, from: data)
    }
    
    func fetchPhotosNextPage(with token: String) {
        synchronizationQueue.async {
            self.semaphore.wait()
            defer { self.semaphore.signal() }
            
            guard !self.isLoading else { return }
            self.isLoading = true
            let nextPage = (self.lastLoadedPage ?? 0) + 1
            
            self.fetch(parameters: ["page": "\(nextPage)", "per_page": "10", "token": token],
                  method: "GET",
                  url: APIEndpoints.Photos.photos) { [weak self] result in
                guard let self else { return }
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
                    Logger.shared.log(.error, 
                                      message: "ImagesListService: Не удалось получить изображения",
                                      metadata: ["❌": error.localizedDescription])
                }
            }
        }
    }
}
// MARK: - Extension
extension ImagesListService {
    
    private func mapToPhotos(photoResult: PhotoResult) -> Photos {
        let dateFormatter = ISO8601DateFormatter()
        let date = photoResult.createdAt.flatMap { dateFormatter.date(from: $0) }
        
        return Photos(id: photoResult.id,
                      size: CGSize(width: photoResult.width,
                                   height: photoResult.height),
                      createdAt: date,
                      welcomeDescription: photoResult.description,
                      thumbImageURL: photoResult.urls.thumb,
                      largeImageURL: photoResult.urls.full,
                      isLiked: photoResult.likedByUser)
    }
}

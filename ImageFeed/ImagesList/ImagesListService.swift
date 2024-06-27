//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 27.06.2024.
//

import Foundation
import Kingfisher

final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photos] = []
    private var lastLoadedPage: Int?
    private var isLoading: Bool = false
    
}

// MARK: - NetworkService
extension ImagesListService: NetworkService {
    typealias Model = [PhotoResult]
    
    func makeRequest(parameters: [String : String], method: String, url: String) -> URLRequest? {
        var components = URLComponents(string: url)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let finalURl = components?.url else {
            Logger.shared.log(.error, message: "Неверная строка URL: \(url)")
            return nil
        }
        
        var request = URLRequest(url: finalURl)
        request.httpMethod = method
        request.setValue("Bearer \(parameters["token"] ?? "")",
                         forHTTPHeaderField: "Authorization")
        
        Logger.shared.log(.debug, message: "Запрос создан: \(request)")
        
        return request
    }
    
    func parse(data: Data) -> [PhotoResult]? {
        let decoder = JSONDecoder()
        return try? decoder.decode([PhotoResult].self, from: data)
    }
    
    func fetchPhotosNextPage(with token: String) {
        guard !isLoading else { return }
        
        isLoading = true
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        fetch(parameters: ["page": "\(nextPage)", "per_page": "100", "token": token], method: "GET", url: APIEndpoints.Photos.photos) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.compactMap { self.mapToPhotos(photoResult: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                Logger.shared.log(.debug, message: "Изображения успешно получены")
                
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
            case .failure(let error):
                Logger.shared.log(.error, message: "Не удалось получить изображения", metadata: ["error": error.localizedDescription])
            }
        }
    }
}

extension ImagesListService {
    
    private func mapToPhotos(photoResult: PhotoResult) -> Photos {
        let dateFormatter = ISO8601DateFormatter()
        let date = photoResult.createdAt.flatMap { dateFormatter.date(from:$0) }
        
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

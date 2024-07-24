//
//  MockImagesListService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 22.07.2024.
//

import Foundation

final class MockImagesListService: ImagesListServiceProtocol {
    var photos: [ImageFeed.Photo] = []
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func fetchPhotosNextPage(with token: String) {
        fetchPhotosNextPageCalled = true
        
        let mockPhotos = [
            Photo(id: "1", size: CGSize(width: 300, height: 200), createdAt: Date(), welcomeDescription: "Test Photo 1", regularImageURL: "https://media.bhsusa.com/neighborhoods/9_5172023_24329.jpg", largeImageURL: "", isLiked: false),
            Photo(id: "2", size: CGSize(width: 300, height: 200), createdAt: Date(), welcomeDescription: "Test Photo 2", regularImageURL: "https://cdn.propertynest.com/images/Brooklyn-Heights.2e16d0ba.fill-685x343.format-jpeg.jpg", largeImageURL: "https://cdn.propertynest.com/images/Brooklyn-Heights.2e16d0ba.fill-685x343.format-jpeg.jpg", isLiked: true)
        ]
        photos.append(contentsOf: mockPhotos)
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                        object: nil,
                                        userInfo: ["startIndex": 0, "endIndex": mockPhotos.count - 1])
    }
    
    func changeLike(photoId: String,
                    isLike: Bool,
                    _ completion: @escaping (Result<ImageFeed.VoidModel, any Error>) -> Void) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            photos[index].isLiked = isLike
            completion(.success(VoidModel()))
        } else {
            completion(.failure(NSError(domain: "Photo not found", code: 404, userInfo: nil)))
        }
    }
}

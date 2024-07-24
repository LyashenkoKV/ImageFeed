//
//  ImagesListPresenterMock.swift
//  ImagesListTests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//
@testable import ImageFeed
import UIKit

final class ImagesListPresenterMock: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var fetchPhotosCalled = false
    var numberOfPhotosReturnValue = 0
    var photoReturnValue: Photo?
    var formatReturnValue = ""
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotos() {
        fetchPhotosCalled = true
    }
    
    func numberOfPhotos() -> Int {
        return numberOfPhotosReturnValue
    }
    
    func photo(at index: Int) -> Photo? {
        return photoReturnValue
    }
    
    func format(date: Date?) -> String {
        return formatReturnValue
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<VoidModel, Error>) -> Void) {
        completion(.success(VoidModel()))
    }
}

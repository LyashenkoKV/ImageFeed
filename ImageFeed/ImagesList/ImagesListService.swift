//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 27.06.2024.
//

import Foundation
import Kingfisher

final class ImagesListService {
    
    private (set) var photos: [Photos] = []
    private var lastLoadedPage: Int?
    
    func fetchPhotosNextPage() {
        
        let nextPage = (lastLoadedPage ?? 0) + 1
    }
}

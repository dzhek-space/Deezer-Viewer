//
//  ImageCache.swift
//  Deezer Playlists
//
//  Created by Dzhek on 31.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import UIKit
import RxSwift

final class ImageCache {
    
    static let publicCache = ImageCache()
    
    let disposeBag = DisposeBag()
    
    private let cachedImages = NSCache<NSString, UIImage>()
    
    func cachedImage(key url: NSString) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    func cacheImageData(for url: NSString) -> Single<Bool> {
        let cache = cachedImages
        return Single<Bool>.create { singleSubject -> Disposable in
            Resource<Data>(endpoint: .image(fromUrl: url as String))
                .fetchData()
                .subscribe(
                    onSuccess: {
                        if let loadedData = UIImage(data: $0) {
                            cache.setObject(loadedData, forKey: url)
                        }
                        else {
                            cache.setObject(Constants.placeholderUnavailableImage, forKey: url)
                        }
                        singleSubject(.success(true))
                    })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
        
    }
    
    func clearCache() {
        cachedImages.removeAllObjects()
    }
        
}


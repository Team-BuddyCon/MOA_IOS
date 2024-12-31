//
//  ImageLoadManager.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import UIKit
import RxSwift
import RxCocoa

final class ImageLoadManager {
    static let shared = ImageLoadManager()
    private init() {}
    
    private let cacheImages = NSCache<NSString, UIImage>()
    
    func load(url: String) -> Observable<UIImage?> {
        guard let imageURL = URL(string: url) else {
            return .just(nil)
        }
        
        if let image = cacheImages.object(forKey: url as NSString) {
            return Observable.just(image)
        }
        
        let request = URLRequest(url: imageURL)
        return URLSession.shared.rx
            .data(request: request)
            .compactMap { $0 }
            .map { [weak self] in
                let image = UIImage(data: $0)
                if let image = image {
                    self?.cacheImages.setObject(image, forKey: url as NSString)
                }
                return image
            }
    }
}

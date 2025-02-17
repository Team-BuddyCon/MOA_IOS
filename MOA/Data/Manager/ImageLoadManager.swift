//
//  ImageLoadManager.swift
//  MOA
//
//  Created by 오원석 on 11/11/24.
//

import UIKit
import RxSwift
import RxCocoa

private let MEMORY_CACHE_LIMIT = 50    // 50MB
private let DISK_CACHE_LIMIT = 200     // 200MB

final class ImageLoadManager {
    static let shared = ImageLoadManager()
    private init() {}
    
    private let fileManager = FileManager.default
    
    private lazy var cacheImages: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = MEMORY_CACHE_LIMIT
        return cache
    }()
    
    func load(
        url: String,
        identifier: String,
        expireDate: String
    ) -> Observable<UIImage?> {
        guard let imageURL = URL(string: url) else {
            return .just(nil)
        }
        
        guard fileManager.urls(for: .documentDirectory, in: .userDomainMask).first != nil else {
            return .just(nil)
        }
        
        if let image = cacheImages.object(forKey: identifier as NSString) {
            return Observable.just(image)
        }
        
        if let image = loadImageFromDiskCache(identifier: identifier, expireDate: expireDate) {
            return Observable.just(image)
        }
        
        let request = URLRequest(url: imageURL)
        return URLSession.shared.rx
            .data(request: request)
            .compactMap { $0 }
            .map { [weak self] in
                guard let self = self else { return nil }
                let image = UIImage(data: $0)
                if let image = image {
                    saveImageFromDiskCache(image: image, identifier: identifier, expireDate: expireDate)
                    cacheImages.setObject(image, forKey: identifier as NSString)
                }
                return image
            }
    }
    
    private func loadImageFromDiskCache(
        identifier: String,
        expireDate: String
    ) -> UIImage? {
        // userDomainMask: 사용자 관련 파일
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsDirectory.appendingPathComponent("\(expireDate)_\(identifier)", conformingTo: .jpeg)
        guard fileManager.fileExists(atPath: fileURL.path()) else { return nil }
        return UIImage(contentsOfFile: fileURL.path())
    }
    
    private func saveImageFromDiskCache(
        image: UIImage,
        identifier: String,
        expireDate: String
    ) {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent("\(expireDate)_\(identifier)", conformingTo: .jpeg)
        MOALogger.logd("\(fileURL)")
        do {
            if getImageCountFromDiskCache() >= DISK_CACHE_LIMIT {
                removeImageFromDiskCache()
            }
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                try imageData.write(to: fileURL)
            }
        } catch {
            MOALogger.loge("\(error.localizedDescription)")
        }
    }
    
    private func removeImageFromDiskCache() {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            guard let lastUploadURL = fileURLs.sorted(by: { url1, url2 in
                url1.absoluteString < url2.absoluteString
            }).last else {
                return
            }
            
            MOALogger.logd("Disk cache is full, removing oldest image \(lastUploadURL)")
            try fileManager.removeItem(at: lastUploadURL)
        } catch {
            MOALogger.loge("\(error.localizedDescription)")
        }
    }
    
    private func getImageCountFromDiskCache() -> Int {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return 0 }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            return fileURLs.count
        } catch {
            MOALogger.loge("\(error.localizedDescription)")
            return 0
        }
    }
}

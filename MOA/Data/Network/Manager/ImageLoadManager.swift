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
    
    func load(url: String) -> Observable<Data?> {
        guard let imageURL = URL(string: url) else {
            return .just(nil)
        }
        
        let request = URLRequest(url: imageURL)
        return URLSession.shared.rx
            .data(request: request)
            .map { $0 as Data? }
    }
}

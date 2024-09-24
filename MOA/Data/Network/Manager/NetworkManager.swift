//
//  NetworkManager.swift
//  MOA
//
//  Created by 오원석 on 9/23/24.
//

import UIKit
import RxSwift
import RxCocoa

final class NetworkManager {
    
    private let session = URLSession.shared
    let shared = NetworkManager()
    
    private init() {}
    
    func request<T: BaseResponse> (
        service: NetworkService,
        method: NetworkMethod,
        query: [String: String?] = [:],
        body: [String: Any] = [:]
    ) -> Observable<Result<T, URLError>> {
        guard var components = URLComponents(string: UrlProvider.getUrl(service: service)) else {
            return .just(.failure(URLError(.badURL)))
        }
        
        components.queryItems = query.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        guard let url = components.url else {
            return .just(.failure(URLError(.badURL)))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if method != .GET {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }

        return session.rx.data(request: request)
            .map { data in
                guard let response = try? JSONDecoder().decode(T.self, from: data) else {
                    return .failure(URLError(.cannotParseResponse))
                }
                return .success(response)
            }.catch { _ in
                return .just(.failure(URLError(.cannotLoadFromNetwork)))
            }
    }
}

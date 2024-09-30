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
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: BaseResponse> (
        request: BaseRequest
    ) -> Observable<Result<T, URLError>> {
        let url = UrlProvider.getDomainUrl(domain: request.domain) + request.path
        guard var components = URLComponents(string: url) else {
            return .just(.failure(URLError(.badURL)))
        }
        
        if !request.query.isEmpty {
            components.queryItems = request.query.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            return .just(.failure(URLError(.badURL)))
        }
        
        var urlReqeuset = URLRequest(url: url)
        urlReqeuset.httpMethod = request.method.rawValue
        
        if request.method != .GET {
            urlReqeuset.httpBody = try? JSONSerialization.data(withJSONObject: request.body, options: [])
            urlReqeuset.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return URLSession.shared.rx.data(request: urlReqeuset)
            .map { data in
                guard let response = try? JSONDecoder().decode(T.self, from: data) else {
                    return .failure(URLError(.cannotParseResponse))
                }
                return .success(response)
            }.catch { error in
                print("network error \(error)")
                return .just(.failure(URLError(.cannotLoadFromNetwork)))
            }
    }
}

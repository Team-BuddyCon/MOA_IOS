//
//  NetworkManager.swift
//  MOA
//
//  Created by 오원석 on 9/23/24.
//

import UIKit
import RxSwift
import RxCocoa

let HEADER_VALUE_APPLICATION_JSON = "application/json"
let HEADER_FIELD_CONTENT_TYPE = "Content-Type"
let HEADER_VALUE_AUTHORIZATION = "Bearer %@"
let HEADER_FIELD_AUTHORIZATION = "Authorization"

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: BaseResponse> (
        request: BaseRequest
    ) -> Observable<Result<T, URLError>> {
        let url = UrlProvider.getDomainUrl(domain: request.domain) + request.path
        guard var components = URLComponents(string: url) else {
            MOALogger.loge(String(describing: URLError.badURL))
            return .just(.failure(URLError(.badURL)))
        }
        
        if !request.query.isEmpty {
            components.queryItems = request.query.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            MOALogger.loge(String(describing: URLError.badURL))
            return .just(.failure(URLError(.badURL)))
        }
        
        var urlReqeuset = URLRequest(url: url)
        urlReqeuset.httpMethod = request.method.rawValue
        
        if !UserPreferences.getAccessToken().isEmpty {
            urlReqeuset.addValue(String(format: HEADER_VALUE_AUTHORIZATION, UserPreferences.getAccessToken()), forHTTPHeaderField: HEADER_FIELD_AUTHORIZATION)
        }
        
        if request.method != .GET {
            urlReqeuset.httpBody = try? JSONSerialization.data(withJSONObject: request.body, options: [])
            urlReqeuset.setValue(HEADER_VALUE_APPLICATION_JSON, forHTTPHeaderField: HEADER_FIELD_CONTENT_TYPE)
        }

        return URLSession.shared.rx.data(request: urlReqeuset)
            .map { data in
                guard let response = try? JSONDecoder().decode(T.self, from: data) else {
                    MOALogger.loge(URLError(.cannotParseResponse).localizedDescription)
                    return .failure(URLError(.cannotParseResponse))
                }
                return .success(response)
            }.catch { error in
                MOALogger.loge(URLError(.cannotLoadFromNetwork).localizedDescription)
                return .just(.failure(URLError(.cannotLoadFromNetwork)))
            }
    }
}

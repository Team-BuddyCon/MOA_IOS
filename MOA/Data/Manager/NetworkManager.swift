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
        
        // URL
        var urlReqeuset = URLRequest(url: url)
        urlReqeuset.httpMethod = request.method.rawValue
        
        // JWT
        if request.domain == .MOA {
            urlReqeuset.addValue(
                String(format: HttpValues.bearer, UserPreferences.getAccessToken()),
                forHTTPHeaderField: HttpKeys.authorization
            )
        } else {
            if let apiKey = Bundle.main.infoDictionary?["RestApiKey"] as? String {
                urlReqeuset.addValue(
                    String(format: HttpValues.kakaoAK, apiKey),
                    forHTTPHeaderField: HttpKeys.authorization
                )
            }
        }
        
        // Content-Type
        urlReqeuset.setValue(request.contentType.rawValue,forHTTPHeaderField: HttpKeys.contentType)
        
        // BODY
        if request.method == .POST || request.method == .PUT {
            switch request.contentType {
            case .application_json:
                urlReqeuset.httpBody = try? JSONSerialization.data(withJSONObject: request.body, options: [])
            case .multipart_form_data:
                let boundary = "\(UUID().uuidString)"
                urlReqeuset.setValue(
                    "\(request.contentType.rawValue); boundary=\(boundary)",
                    forHTTPHeaderField: HttpKeys.contentType
                )
                urlReqeuset.httpBody = getMultipartFormData(body: request.body, boundary: boundary)
            }
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
    
    private func getMultipartFormData(body: [String: Any], boundary: String) -> Data {
        let boundaryPrefix = "--\(boundary)\r\n"
        let boundarySuffix = "--\r\n"
        let boundaryTerminator = "--\(boundary)--\r\n"
        
        var data = Data()
        let jsonBody: [String: Any] = body.filter { $0.key != HttpKeys.Gifticon.image }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) {
            data.append(boundaryPrefix.data(using: .utf8)!)
            data.append("\(HttpKeys.contentDisposition): \(HttpValues.formData); \(HttpKeys.name)=\"\(HttpKeys.Gifticon.dto)\"\r\n".data(using: .utf8)!)
            data.append("\(HttpKeys.contentType): \(HttpValues.applicationJson)\r\n\r\n".data(using: .utf8)!)
            data.append(jsonData)
            data.append(boundarySuffix.data(using: .utf8)!)
        }
    
        let filename = "image.jpg"
        let mimetype = "image/jpeg"
                   
        data.append(boundaryPrefix.data(using: .utf8)!)
        data.append("\(HttpKeys.contentDisposition): \(HttpValues.formData); \(HttpKeys.name)=\"\(HttpKeys.Gifticon.image)\"; \(HttpKeys.filename)=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("\(HttpKeys.contentType): \(mimetype)\r\n\r\n".data(using: .utf8)!)
        
        if let dataValue = body[HttpKeys.Gifticon.image] as? Data {
            data.append(dataValue)
        }
        
        data.append(boundarySuffix.data(using: .utf8)!)
        data.append(boundaryTerminator.data(using: .utf8)!)
        
        return data
    }
}

//
//  BaseRequest.swift
//  MOA
//
//  Created by 오원석 on 9/29/24.
//

import Foundation

protocol BaseRequest {
    var domain: HttpDomain { get }
    var path: String { get }
    var method: HttpMethod { get }
    var query: [String: String?] { get }
    var body: [String: Any] { get }
    var contentType: HttpContentType { get }
}


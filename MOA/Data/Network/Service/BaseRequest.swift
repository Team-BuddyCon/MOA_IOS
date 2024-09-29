//
//  BaseRequest.swift
//  MOA
//
//  Created by 오원석 on 9/29/24.
//

import Foundation

protocol BaseRequest {
    var domain: NetworkDomain { get }
    var path: String { get }
    var method: NetworkMethod { get }
    var query: [String: String?] { get }
    var body: [String: Any] { get }
}


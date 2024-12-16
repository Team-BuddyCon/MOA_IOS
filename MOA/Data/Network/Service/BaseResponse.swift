//
//  BaseResponse.swift
//  MOA
//
//  Created by 오원석 on 9/23/24.
//

import Foundation

protocol BaseResponse: Decodable {
    var status: Int { get }
    var message: String { get }
}

extension BaseResponse {
    var isSuccess: Bool { status == 200 }
}

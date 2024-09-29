//
//  BaseResponse.swift
//  MOA
//
//  Created by 오원석 on 9/23/24.
//

import Foundation

protocol BaseResponse: Decodable {
    var status: Int { get set }
    var message: String { get set }
}

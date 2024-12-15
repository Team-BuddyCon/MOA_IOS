//
//  DeleteGifticonResponse.swift
//  MOA
//
//  Created by 오원석 on 12/15/24.
//

import Foundation

struct DeleteGifticonResponse: BaseResponse {
    var status: Int
    var message: String
    
    var isSuccess: Bool { status == 200 }
}

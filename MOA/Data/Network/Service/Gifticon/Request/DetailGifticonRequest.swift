//
//  DetailGifticonRequest.swift
//  MOA
//
//  Created by 오원석 on 12/12/24.
//

import Foundation

struct DetailGifticonRequest:  BaseRequest {
    var domain: HttpDomain { .MOA }
    
    var path: String { "\(HttpPath.Gifticon.Detail)/\(gifticonId)" }
    
    var method: HttpMethod { .GET }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .application_json }
    
    var gifticonId: Int
    
    init(gifticonId: Int) {
        self.gifticonId = gifticonId
        self.query = [:]
        self.body = [:]
    }
}

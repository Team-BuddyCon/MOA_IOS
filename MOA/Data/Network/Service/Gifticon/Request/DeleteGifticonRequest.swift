//
//  DeleteGifticonRequest.swift
//  MOA
//
//  Created by 오원석 on 12/15/24.
//

import Foundation

struct DeleteGifticonRequest: BaseRequest {
    var domain: HttpDomain { .MOA }
    
    var path: String { HttpPath.Gifticon.Detail }
    
    var method: HttpMethod { .DELETE }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .application_json }
    
    init(gifticonId: Int) {
        var query: [String : String?] = [:]
        query.updateValue(String(gifticonId), forKey: HttpKeys.Gifticon.gifticonId)
        
        self.query = query
        self.body = [:]
    }
}

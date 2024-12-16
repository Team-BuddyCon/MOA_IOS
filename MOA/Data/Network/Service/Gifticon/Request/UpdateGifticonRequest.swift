//
//  UpdateGifticonRequest.swift
//  MOA
//
//  Created by 오원석 on 12/15/24.
//

import Foundation

struct UpdateGifticonRequest: BaseRequest {
    var domain: HttpDomain { .MOA }
    
    var path: String { "\(HttpPath.Gifticon.Detail)/\(gifticonId)" }
    
    var method: HttpMethod { .PUT }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .application_json }
    
    var gifticonId: Int
    
    init(
        gifticonId: Int,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) {
        self.gifticonId = gifticonId
        
        var body: [String: Any] = [:]
        body.updateValue(name, forKey: HttpKeys.Gifticon.name)
        body.updateValue(expireDate, forKey: HttpKeys.Gifticon.expireDate)
        body.updateValue(store, forKey: HttpKeys.Gifticon.store)
        
        if let memo = memo {
            body.updateValue(memo, forKey: HttpKeys.Gifticon.memo)
        }
        
        self.query = [:]
        self.body = body
    }
}

//
//  CreateGifticonRequest.swift
//  MOA
//
//  Created by 오원석 on 12/9/24.
//

import Foundation

struct CreateGifticonRequest: BaseRequest {
    var domain: HttpDomain { .MOA }
    
    var path: String { HttpPath.Gifticon.Create }
    
    var method: HttpMethod { .POST }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .multipart_form_data }
    
    init(
        image: Data,
        name: String,
        expireDate: String,
        store: String,
        memo: String?
    ) {
        var body: [String: Any] = [:]
        body.updateValue(image, forKey: HttpKeys.Gifticon.image)
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

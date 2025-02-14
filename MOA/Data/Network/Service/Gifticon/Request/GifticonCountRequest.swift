//
//  GifticonCountRequest.swift
//  MOA
//
//  Created by 오원석 on 1/10/25.
//

import Foundation

struct GifticonCountRequest: BaseRequest {
    var domain: HttpDomain { .MOA }
    
    var path: String { HttpPath.Gifticon.Count }
    
    var method: HttpMethod { .GET }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .application_json }
    
    init(
        used: Bool,
        storeCategory: StoreCategory?,
        storeType: StoreType?,
        remainingDays: Int?
    ) {
        var query: [String: String?] = [:]
        query.updateValue(String(used), forKey: HttpKeys.Gifticon.used)
        
        if let storeCategory = storeCategory, storeCategory != .ALL {
            query.updateValue(String(describing: storeCategory), forKey: HttpKeys.Gifticon.gifticonStoreCategory)
        }
        
        if let storeType = storeType {
            query.updateValue(String(describing: storeType), forKey: HttpKeys.Gifticon.gifticonStore)
        }
        
        if let remainingDays = remainingDays {
            query.updateValue(String(remainingDays), forKey: HttpKeys.Gifticon.remainingDays)
        }
        
        self.query = query
        self.body = [:]
    }
}

//
//  UnAvailableGifticonRequest.swift
//  MOA
//
//  Created by 오원석 on 1/10/25.
//

import Foundation

struct UnAvailableGifticonRequest: BaseRequest {
    var domain: HttpDomain { .MOA }
    
    var path: String { HttpPath.Gifticon.UnAvailable }
    
    var method: HttpMethod { .GET }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .application_json }
    
    init(
        pageNumber: Int,
        rowCount: Int
    ) {
        var query: [String: String?] = [:]
        query.updateValue(String(pageNumber), forKey: HttpKeys.Gifticon.pageNumber)
        query.updateValue(String(rowCount), forKey: HttpKeys.Gifticon.rowCount)
        
        self.query = query
        self.body = [:]
    }
}

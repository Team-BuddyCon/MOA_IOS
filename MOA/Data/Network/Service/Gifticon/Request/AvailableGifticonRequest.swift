//
//  AvailableGifticonRequest.swift
//  MOA
//
//  Created by 오원석 on 11/12/24.
//

import Foundation

struct AvailableGifticonRequest: BaseRequest {
    var domain: HttpDomain { .MOA }
    
    var path: String { HttpPath.Gifticon.Available }
    
    var method: HttpMethod { .GET }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .application_json }
    
    init(
        pageNumber: Int,
        rowCount: Int,
        storeCategory: StoreCategory?,
        storeType: StoreType?,
        sortType: SortType?
    ) {
        var query: [String: String?] = [:]
        query.updateValue(String(pageNumber), forKey: HttpKeys.Gifticon.pageNumber)
        query.updateValue(String(rowCount), forKey: HttpKeys.Gifticon.rowCount)
        
        if let storeCategory = storeCategory, storeCategory != .All {
            query.updateValue(String(describing: storeCategory), forKey: HttpKeys.Gifticon.gifticonStoreCategory)
        }
        
        if let storeType = storeType {
            query.updateValue(String(describing: storeType), forKey: HttpKeys.Gifticon.gifticonStore)
        }
        
        if let sortType = sortType {
            query.updateValue(String(describing: sortType), forKey: HttpKeys.Gifticon.gifticonSortType)
        }
        
        self.query = query
        self.body = [:]
    }
}

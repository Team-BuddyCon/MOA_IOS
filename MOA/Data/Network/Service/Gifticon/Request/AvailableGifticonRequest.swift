//
//  AvailableGifticonRequest.swift
//  MOA
//
//  Created by 오원석 on 11/12/24.
//

import Foundation

let AVAILABLE_GIFTICON_PATH = "/api/v1/gifticons/available"
let AVAILABLE_GIFTICON_PAGE_NUMBER = "pageNumber"
let AVAILABLE_GIFTICON_ROW_COUNT = "rowCount"
let AVAILABLE_GIFTICON_STORE_CATEGORY = "gifticonStoreCategory"
let AVAILABLE_GIFTICON_STORE = "gifticonStore"
let AVAILABLE_GIFTICON_SORT_TYPE = "gifticonSortType"

final class AvailableGifticonRequest: BaseRequest {
    var domain: NetworkDomain { .MOA }
    
    var path: String { AVAILABLE_GIFTICON_PATH }
    
    var method: NetworkMethod { .GET }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    init(
        pageNumber: Int,
        rowCount: Int,
        storeCategory: StoreCategory,
        sortType: SortType
    ) {
        var query: [String: String?] = [:]
        query.updateValue(String(pageNumber), forKey: AVAILABLE_GIFTICON_PAGE_NUMBER)
        query.updateValue(String(rowCount), forKey: AVAILABLE_GIFTICON_ROW_COUNT)
        query.updateValue(String(describing: storeCategory), forKey: AVAILABLE_GIFTICON_STORE_CATEGORY)
        query.updateValue(String(describing: sortType), forKey: AVAILABLE_GIFTICON_SORT_TYPE)
        self.query = query
        self.body = [:]
        
        "http://3.37.254.182:8080/api/v1/gifticons/available?gifticonStoreCategory=CONVENIENCE_STORE&rowCount=20&pageNumber=0&gifticonSortType=EXPIRATION_DATE"
        "http://3.37.254.182:8080/api/v1/gifticons/available?pageNumber=0&gifticonStoreCategory=CONVENIENCE_STORE&gifticonSortType=EXPIRE_DATE&rowCount=10 "
    }
}

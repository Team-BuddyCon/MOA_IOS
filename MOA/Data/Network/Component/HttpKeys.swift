//
//  NetworkConfig.swift
//  MOA
//
//  Created by 오원석 on 12/10/24.
//

struct HttpKeys {
    static let contentType = "Content-Type"
    static let authorization = "Authorization"
    static let contentDisposition = "Content-Disposition"
    static let name = "name"
    static let filename = "filename"
    
    struct Auth {
        static let oauthAccessToken = "oauthAccessToken"
        static let nickname = "nickname"
        static let email = "email"
        static let gender = "gender"
        static let age = "age"
    }
    
    struct Gifticon {
        static let image = "image"
        static let name = "name"
        static let expireDate = "expireDate"
        static let store = "store"
        static let memo = "memo"
        static let pageNumber = "pageNumber"
        static let rowCount = "rowCount"
        static let gifticonStoreCategory = "gifticonStoreCategory"
        static let gifticonStore = "gifticonStore"
        static let gifticonSortType = "gifticonSortType"
        static let dto = "dto"
        static let gifticonId = "gifticonId"
        static let used = "used"
    }
    
    struct Kakao {
        static let query = "query"
        static let x = "x"
        static let y = "y"
        static let radius = "radius"
    }
}

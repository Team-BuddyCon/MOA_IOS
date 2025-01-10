//
//  HttpPath.swift
//  MOA
//
//  Created by 오원석 on 12/10/24.
//

struct HttpPath {
    struct Auth {
        static let Login = "/api/v1/auth/login"
    }
    
    struct Gifticon {
        static let Create = "/api/v1/gifticons"
        static let Available = "/api/v1/gifticons/available"
        static let Detail = "/api/v1/gifticons"
        static let UnAvailable = "/api/v1/gifticons/unavailable"
        static let Count = "/api/v1/gifticons/count"
    }
    
    struct Kakao {
        static let SearchPlaceByKeyword = "/local/search/keyword"
    }
}

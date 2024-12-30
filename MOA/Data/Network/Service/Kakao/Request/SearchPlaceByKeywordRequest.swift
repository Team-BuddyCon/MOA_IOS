//
//  SearchPlaceByKeywordRequest.swift
//  MOA
//
//  Created by 오원석 on 12/30/24.
//

struct SearchPlaceByKeywordRequest: BaseRequest {
    var domain: HttpDomain { .KAKAO }
    
    var path: String { HttpPath.Kakao.SearchPlaceByKeyword }
    
    var method: HttpMethod { .GET }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .application_json }
    
    init(
        query: String,
        x: String,
        y: String,
        radius: Int
    ) {
        var queryDic: [String: String?] = [:]
        queryDic.updateValue(query, forKey: HttpKeys.Kakao.query)
        queryDic.updateValue(x, forKey: HttpKeys.Kakao.x)
        queryDic.updateValue(y, forKey: HttpKeys.Kakao.y)
        queryDic.updateValue(String(radius), forKey: HttpKeys.Kakao.radius)
        
        self.query = queryDic
        self.body = [:]
    }
}

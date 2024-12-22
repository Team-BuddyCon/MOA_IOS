//
//  Untitled.swift
//  MOA
//
//  Created by 오원석 on 12/22/24.
//

struct UpdateUsedGifticonRequest: BaseRequest {
    var domain: HttpDomain { .MOA }
    
    var path: String { "\(HttpPath.Gifticon.Detail)/\(gifticonId)" }
    
    var method: HttpMethod { .PATCH }
    
    var query: [String : String?]
    
    var body: [String : Any]
    
    var contentType: HttpContentType { .application_json }
    
    var gifticonId: Int
    
    init(
        gifticonId: Int,
        used: Bool
    ) {
        self.gifticonId = gifticonId
        
        var query: [String: String?] = [:]
        query.updateValue(String(used), forKey: HttpKeys.Gifticon.used)
        
        self.query = query
        self.body = [:]
    }
}

//
//  Regex+.swift
//  MOA
//
//  Created by 오원석 on 8/15/25.
//

import Foundation

extension Regex {
    static func extractDate(str: String) -> String? {
        let datePattern = /\d{4}(\.\d{2}\.\d{2}|년\s*\d{2}월\s*\d{2}일)/
        return str.firstMatch(of: datePattern).map { match in
            String(match.0)
        }
    }
    
    static func extractStoreType(str: String) -> String? {
        let storeTypePattern = /스타벅스|투썸플레이스|엔젤리너스|메가커피|커피빈|공차|베스킨라빈스|맥도날드|GS25|CU/
        return str.firstMatch(of: storeTypePattern).map { match in
            String(match.0)
        }
    }
}

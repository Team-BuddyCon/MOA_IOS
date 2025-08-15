//
//  Regex+.swift
//  MOA
//
//  Created by 오원석 on 8/15/25.
//

import Foundation

extension Regex {
    /// Extracts the first date-like substring from the given string.
    /// 
    /// Recognizes two formats:
    /// - `YYYY.MM.DD` (four-digit year, two-digit month, two-digit day separated by dots)
    /// - Korean form: `년` followed by `MM월` and `DD일` (whitespace between tokens allowed)
    /// - Parameters:
    ///   - str: The string to search for a date.
    /// - Returns: The first matched date substring in its original form, or `nil` if no date is found.
    static func extractDate(str: String) -> String? {
        let datePattern = /\d{4}(\.\d{2}\.\d{2}|년\s*\d{2}월\s*\d{2}일)/
        return str.firstMatch(of: datePattern).map { match in
            String(match.0)
        }
    }
    
    /// Extracts the first recognized store name from the given string.
    /// - Parameters:
    ///   - str: The string to search for a store name.
    /// - Returns: The first matched store name (one of "스타벅스", "투썸플레이스", "엔젤리너스", "메가커피", "커피빈", "공차", "베스킨라빈스", "맥도날드", "GS25", "CU"), or `nil` if no match is found.
    static func extractStoreType(str: String) -> String? {
        let storeTypePattern = /스타벅스|투썸플레이스|엔젤리너스|메가커피|커피빈|공차|베스킨라빈스|맥도날드|GS25|CU/
        return str.firstMatch(of: storeTypePattern).map { match in
            String(match.0)
        }
    }
}

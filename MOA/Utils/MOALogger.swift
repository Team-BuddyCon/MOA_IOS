//
//  Logger.swift
//  MOA
//
//  Created by 오원석 on 10/20/24.
//

import Foundation
import OSLog

struct MOALogger {
    private static let logger = Logger()
    
    static func logd(
        _ message: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let message = message != nil ? ": \(String(describing: message))" : ""
        logger.debug("\(file.components(separatedBy: "/").last ?? "")(\(line)) \(function)\(message)")
    }
    
    static func logi(
        _ message: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let message = message != nil ? ": \(String(describing: message))" : ""
        logger.info("\(file.components(separatedBy: "/").last ?? "")(\(line)) \(function)\(message)")
    }
    
    static func loge(
        _ message: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let message = message != nil ? ": \(String(describing: message))" : ""
        logger.error("\(file.components(separatedBy: "/").last ?? "")(\(line)) \(function)\(message)\n\(Thread.callStackSymbols.prefix(10).joined(separator: "\n"))")
    }
}

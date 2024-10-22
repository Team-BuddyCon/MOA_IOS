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
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logger.debug("\(file.components(separatedBy: "/").last ?? "")(\(line)) \(function): \(message)")
    }
    
    static func logi(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logger.info("\(file.components(separatedBy: "/").last ?? "")(\(line)) \(function): \(message)")
    }
    
    static func loge(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logger.error("\(file.components(separatedBy: "/").last ?? "")(\(line)) \(function): \(message)\n\(Thread.callStackSymbols.prefix(10).joined(separator: "\n"))")
    }
}

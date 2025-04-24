//
//  DebugLogger.swift
//  GrowSpacePrivateSDK
//
//  Created by min gwan choi on 3/27/25.
//

import os

struct DebugLogger {
    private static let logger = Logger(subsystem: "com.freegrow.sdk", category: "GrowSpaceSDK")

    static func debug(_ message: String) {
        #if DEBUG
        logger.debug("🐛 [DEBUG] \(message, privacy: .public)")
        #endif
    }

    static func info(_ message: String) {
        #if DEBUG
        logger.info("🔔 [INFO] \(message, privacy: .public)")
        #endif
    }

    static func error(_ message: String) {
        #if DEBUG
        logger.error("❌ [ERROR] \(message, privacy: .public)")
        #endif
    }

    static func warning(_ message: String) {
        #if DEBUG
        logger.warning("⚠️ [WARNING] \(message, privacy: .public)")
        #endif
    }
}

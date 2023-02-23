//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/1/30.
//

import Foundation

struct GZLog {
    static func log(_ msg: String, type: LogType) {
        switch type {
        case .info:
            print("##### \(msg)")
            break
        case .error:
            print("❎ error: \(msg.isEmpty ? "无" : msg)")
            break
        case .fatalError:
            print("❎ error: \(msg.isEmpty ? "无" : msg)")
            abort()
        case .begin:
            print("##### \(msg)... #####")
            break
        case .end:
            print("✅ \(msg) ")
            break
        }
    }
}

enum LogType {
    case info
    case begin
    case end
    case error
    case fatalError
}

//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/1/30.
//

import Foundation

enum ExecuteShellStatus {
    case success
    case failed
}

struct GZShellExecute {
    @discardableResult
    static func execute(_ args: [String]) -> (String, ExecuteShellStatus) {
        let task = Process()
        let newArgs: [String] = ["-c"]
        task.launchPath = "/bin/bash"
        task.arguments = newArgs + args
        let pipe = Pipe()
        task.standardOutput = pipe
    //        task.standardError = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) ?? ""
        let status: ExecuteShellStatus = task.terminationStatus == 0 ? .success : .failed
        return (output, status)
    }
}

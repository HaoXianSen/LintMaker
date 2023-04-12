//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/1/30.
//

import Foundation

public enum ExecuteShellStatus {
    case success
    case failed
}

@discardableResult
public func scriptExecute(_ args: [String]) -> (status: ExecuteShellStatus, stdout: String, stderr: String) {
    let task = Process()
    let newArgs: [String] = ["-c"]
    task.launchPath = "/bin/bash"
    task.arguments = newArgs + args
    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    task.standardOutput = stdoutPipe
    task.standardError = stderrPipe
    task.launch()
    
    let group = DispatchGroup(), queue = DispatchQueue.global()
    var stdoutData: Data?, stderrData: Data?
    queue.async(group: group) {stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()}
    queue.async(group: group, execute: {stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()})
    task.waitUntilExit()
    group.wait()
    
    let output: String = stdoutData.flatMap { String(data: $0, encoding: .utf8)} ?? ""
    let errOutput: String = stderrData.flatMap { String(data: $0, encoding: .utf8)} ?? ""
    let status: ExecuteShellStatus = task.terminationStatus == 0 ? .success : .failed
    return (status, output, errOutput)
}

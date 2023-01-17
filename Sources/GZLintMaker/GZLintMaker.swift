import ArgumentParser
import Foundation
import OSLog

let clangFile = ".clang-format"
let preCommitHookFile = ".pre-commit-config.yaml"
let swiftLintFile = ".swiftlint.yml"

@main
struct LintMaker: AsyncParsableCommand {
    
    @Option(name: .shortAndLong, help: "Please input a file path")
    var path: String?
    
    @Option(name: .shortAndLong, help: "Please input a clone path, like https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git, contains .clang-format .pre-commit-config.yaml .swiftlint.yml")
    var clonePath: String = "https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git"
    
    @Flag(name: .long, help: "Clean current work space")
    var clean: Bool = false
    
    // 1. clone 文件夹到当前目录或者给定目录
    // 2 cp 相关文件到当前目录或者给定目录
    @available(macOS 10.15.0, *)
    func run() async throws {
        
        let workPath = self.path != nil ? self.path : executeShell(["pwd"]).0
        
        guard let path = workPath else {
            GZLog.log("获取当前目录出错...", type: .fatalError)
            return
        }
        
        if clean == true {
            cleanWorkSpace(currentDirectory: path)
            return
        }
        
        let lintRespository = URL(string: clonePath)?.deletingPathExtension().lastPathComponent ?? "gzlint"
        GZLog.log(lintRespository, type: .info)
        let destinationPath = URL(fileURLWithPath: path.replacingOccurrences(of: "\n", with: "")).appendingPathComponent(lintRespository).path
        executeShell(["cd \(path)"])
        
        cleanWorkSpace(currentDirectory: path)
        
        
        GZLog.log("开始下载远程资源请稍后...", type: .info)
        let output = executeShell(["git clone \(clonePath)"]).1
        
        guard output == .success else {
            GZLog.log("下载资源文件失败，具体地址：\(clonePath)", type: .fatalError)
            return
        }
        
        GZLog.log("下载完成", type: .info)
        
        
        
        if FileManager.default.fileExists(atPath: destinationPath) == true {
            GZLog.log("移动配置文件到当前工作目录...", type: .info)
            let result = executeShell(["mv \(destinationPath)/\(clangFile) \(destinationPath)/\(preCommitHookFile) \(destinationPath)/\(swiftLintFile) \(path)"])
            if result.1 == .failed {
                print("移动文件失败...(失败原因：\(result.0)")
                return
            }
            GZLog.log("移动配置文件完成", type: .info)
            
            try? FileManager.default.removeItem(atPath: destinationPath)
        }
        
    }
    
    @discardableResult
    private func executeShell(_ args: [String]) -> (String, ExecuteShellStatus) {
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
    
    private func cleanWorkSpace(currentDirectory: String) {
        GZLog.log("清理原有文件...", type: .info)
        let fm = FileManager.default
        var isDirectory: ObjCBool = ObjCBool(false)
        let lintRespository = URL(string: clonePath)?.deletingPathExtension().lastPathComponent ?? "gzlint"
        let trimingCurrentDirectory = currentDirectory.replacingOccurrences(of: "\n", with: "")
        let lintRespositoryPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(lintRespository).path
        let clangPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(clangFile).path
        let preCommitHookPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(preCommitHookFile).path
        let swiftLintPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(swiftLintFile).path
        
        if fm.fileExists(atPath: lintRespositoryPath, isDirectory: &isDirectory) {
            try? fm.removeItem(atPath: lintRespositoryPath)
        }
        
        if fm.fileExists(atPath: clangPath, isDirectory: &isDirectory) {
            try? fm.removeItem(atPath: clangPath)
        }
        
        if fm.fileExists(atPath: preCommitHookPath, isDirectory: &isDirectory) {
            try? fm.removeItem(atPath: preCommitHookPath)
        }
        
        if fm.fileExists(atPath: swiftLintPath, isDirectory: &isDirectory) {
            try? fm.removeItem(atPath: swiftLintPath)
        }
        
        GZLog.log("清理完成", type: .info)
    }
}

struct GZLog {
    static func log(_ msg: String, type: LogType) {
        switch type {
        case .info:
            print("======== \(msg)")
            break
        case .error:
            print("error: \(msg.isEmpty ? "无" : msg)")
            break
        case .fatalError:
            print("error: \(msg.isEmpty ? "无" : msg)")
            abort()
        }
    }
}

enum ExecuteShellStatus {
    case success
    case failed
}

enum LogType {
    case info
    case error
    case fatalError
}

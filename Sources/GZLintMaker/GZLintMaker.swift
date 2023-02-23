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
    
    @Flag(name: .long)
    var install: Bool = true
    
    // 1. clone 文件夹到当前目录或者给定目录
    // 2 cp 相关文件到当前目录或者给定目录
    @available(macOS 10.15.0, *)
    func run() async throws {
        
        // 获取当前目录
        let workPath = self.path != nil ? self.path : GZShellExecute.execute(["pwd"]).0
        
        guard let path = workPath else {
            GZLog.log("Get current execute directory failed...", type: .fatalError)
            return
        }
        
        // 清理当前目录空间
        if clean == true {
            cleanWorkSpace(currentDirectory: path)
            return
        }
        
        // 下载远程库
        let lintRespository = URL(string: clonePath)?.deletingPathExtension().lastPathComponent ?? "gzlint"
        let destinationPath = URL(fileURLWithPath: path.replacingOccurrences(of: "\n", with: "")).appendingPathComponent(lintRespository).path
        GZShellExecute.execute(["cd \(path)"])
        
        cleanWorkSpace(currentDirectory: path)
        
        
        GZLog.log("Downloading remote resources...", type: .begin)
        let output = GZShellExecute.execute(["git clone \(clonePath)"]).1
        
        guard output == .success else {
            GZLog.log("Download failed，please check：\(clonePath)", type: .fatalError)
            return
        }
        
        GZLog.log("Download completed", type: .end)
        
        
        // copy 资源到目录，完事删除远程目录
        guard FileManager.default.fileExists(atPath: destinationPath) == true else {
            return
        }
        
        GZLog.log("Moving config file to workspace", type: .begin)
        let result = GZShellExecute.execute(["mv \(destinationPath)/\(clangFile) \(destinationPath)/\(preCommitHookFile) \(destinationPath)/\(swiftLintFile) \(path)"])
        if result.1 == .failed {
            GZLog.log("Moving failed ...(reason：\(result.0)", type: .fatalError)
            return
        }
        GZLog.log("Move config file has completed", type: .end)
        
        try? FileManager.default.removeItem(atPath: destinationPath)
        
        GZCheckTools.check()
        
    }
    
    private func cleanWorkSpace(currentDirectory: String) {
        GZLog.log("Clean workspace", type: .begin)
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
        
        GZLog.log("Clean completed", type: .end)
    }
}

//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/6/7.
//

import Foundation
import ArgumentParser

// MARK: - install

extension LintMaker {
    
    struct InstallSubCommand: AsyncParsableCommand {
        
        @Option(name: .shortAndLong, help: "Please input a workspace path")
        var projectPath: String?
        
        @Option(name: .shortAndLong, help: "Please input a accessible url, like https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git, contains .clang-format .swiftlint.yml")
        var configureGitPath: String = "https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git"
        
        static var configuration: CommandConfiguration = {
            let commandConfiguration = CommandConfiguration(commandName: "install")
            return commandConfiguration
        }()
        
        @available(macOS 10.15.0, *)
        func run() async throws {
            // 获取项目工作目录
            let workspace = self.projectPath != nil ? self.projectPath : scriptExecute(["pwd"]).1
            
            guard let path = workspace else {
                printFatalError("Get current execute directory failed...")
            }
            
            guard let downloadPath = URL(string: self.configureGitPath) else {
                printFatalError("[error] Configuration files download failed，please check --configure-git-path param")
            }
            
            CleanWorkspace.run(path)
            
            // 下载Config 文件
            ConfigurationFileInstall.run(workspace: path, downloadPath: downloadPath)
            
            // 安装lint 工具
            LinterToolsManager.installTools()
        }
    }
}

struct ConfigurationFileInstall {
    
    static func run(workspace: String, downloadPath: URL) {
        downloadFileAndCopy(with: workspace, downloadPath: downloadPath)
    }
    
    // MARK: - 下载配置文件 & 移动到工作空间根目录
    private static func downloadFileAndCopy(with workspace: String, downloadPath: URL) {
        
        mPrint("Downloading or Updating Configuration file...")
        
        let lastPathComponent = downloadPath.deletingPathExtension().lastPathComponent
        let cacheDirectory = NSHomeDirectory() + "/Library/Caches/"
        let configurationGitPath = cacheDirectory + lastPathComponent
        let configurationGitExist = FileManager.default.fileExists(atPath: configurationGitPath)
        
        var result = (ExecuteShellStatus.failed, "")
        if configurationGitExist == false {
            printInfo("clone configuration file")
            result = scriptExecute(["cd \(cacheDirectory) && git clone \(downloadPath) && git pull"])
        } else {
            printInfo("pull configuration file")
            result = scriptExecute(["cd \(configurationGitPath) && git pull"])
        }
        
        guard result.0 == .success else {
            printFatalError("Download Or Update Configuration file failed，please check：\(downloadPath)")
        }
        
        printInfo("Download or Update configuration file completed")
        
        mPrint("Moving configuration files to workspace ...")
        
        let trimingWorkspacePath = workspace.replacingOccurrences(of: "\n", with: "")
        // copy 资源到目录，完事删除远程目录
        guard FileManager.default.fileExists(atPath: configurationGitPath) == true else {
            return
        }
        
        do {
            let fileManager = FileManager.default
            try fileManager.copyItem(atPath: "\(configurationGitPath)/\(clangFileName)", toPath: "\(trimingWorkspacePath)/\(clangFileName)")
            try fileManager.copyItem(atPath: "\(configurationGitPath)/\(swiftLintFile)", toPath: "\(trimingWorkspacePath)/\(swiftLintFile)")
            try fileManager.copyItem(atPath: "\(configurationGitPath)/\(precommitHookScriptFile)", toPath: "\(trimingWorkspacePath)/\(precommitHookScriptPath)")
        } catch let error as NSError {
            printFatalError("[error] Moving failed (reason：\(error))")
        } catch {
            printFatalError("[error] Moving failed (reason：未知)")
        }
        
        printInfo("Moving success!")
    }
}

//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/6/7.
//

import Foundation
import ArgumentParser

// MARK: - 清理工作空间

extension LintMaker {
    struct CleanCommand: ParsableCommand {
        
        @Option(name: .shortAndLong, help: "Please input a workspace path")
        var projectPath: String?
        
        @Option(name: .shortAndLong, help: "Please input a accessible url, like https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git, contains .clang-format .swiftlint.yml")
        var configureGitPath: String = "https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git"
        
        static var configuration: CommandConfiguration {
            return CommandConfiguration(commandName: "clean")
        }
        
        @available(macOS 10.15.0, *)
        func run() throws {
            let workspace = self.projectPath != nil ? self.projectPath : scriptExecute(["pwd"]).1
            
            guard let path = workspace else {
                printFatalError("Get current execute directory failed...")
            }
            
            CleanWorkspace.run(path)
        }
    }
    
}

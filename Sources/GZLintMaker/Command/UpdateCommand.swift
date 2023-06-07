//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/6/7.
//

import Foundation
import ArgumentParser

struct UpdateCommand: ParsableCommand {
    @Option(name: .shortAndLong, help: "a git workspace path, if not set defult is current directory")
    var projectPath: String?
    
    @Option(name: .shortAndLong, help: "Please input a accessible url, like https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git, contains .clang-format .swiftlint.yml")
    var configureGitPath: String = "https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git"
    
    @Flag(name: .long, help: "if set --configuration-only, only update configuration file")
    var configurationOnly: Bool = false
    
    @Flag(name: .long, help: "if set --lint-only, only update lint tools")
    var lintOnly: Bool = false
    
    static var configuration: CommandConfiguration {
        return CommandConfiguration(commandName: "update")
    }
    
    func run() throws {
        // 获取项目工作目录
        let workspace = self.projectPath != nil ? self.projectPath : scriptExecute(["pwd"]).1
        
        guard let path = workspace,
              let configurationURL = URL(string: self.configureGitPath) else {
            printFatalError("Get current execute directory failed...")
        }
        
        if self.configurationOnly {
            CleanWorkspace.run(path)
            
            ConfigurationFileInstall.run(workspace: path, downloadPath: configurationURL)
            return
        }
        
        if self.lintOnly {
            LinterToolsManager.updateTools()
            return
        }
        
        CleanWorkspace.run(path)
        
        ConfigurationFileInstall.run(workspace: path, downloadPath: configurationURL)
        
        LinterToolsManager.updateTools()
    }
}

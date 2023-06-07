//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/6/7.
//

import Foundation
import ArgumentParser

struct UninstallCommand: ParsableCommand {
    
    static var configuration: CommandConfiguration {
        return CommandConfiguration(commandName: "uninstall")
    }
    
    func run() throws {
        LinterToolsManager.uninstallTools()
    }
}

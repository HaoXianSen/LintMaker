//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/1/30.
//

import Foundation

struct GZCheckTools {
    
    @discardableResult
    static func check() -> Bool {
        GZLog.log("Checking lint tools...", type: .begin)
        
        /// homebrew
        if GZShellExecute.execute(["brew -v"]).1 == .success {
            GZLog.log("homebrew has installed", type: .end)
        } else {
            GZLog.log("homebrew installing...", type: .begin)
            let result = GZShellExecute.execute(["-c", "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"]).1
            let msg = result == .success ? "homebrew installed 🍺🍺🍺 /n" : "homebrew install failed😭"
            let logType: LogType = result == .success ? .end : .fatalError
            GZLog.log(msg, type: logType)
            if result == .failed {
                return false
            }
        }
        
        /// pre-commit
        if GZShellExecute.execute(["pre-commit"]).1 == .success {
            GZLog.log("pre-commit has installed", type: .end)
        } else {
            GZLog.log("pre-commit installing...", type: .begin)
            let result = GZShellExecute.execute(["brew install pre-commit"]).1
            let msg = result == .success ? "pre-commit installed 🍺🍺🍺 /n" : "pre-commit install failed😭"
            let logType: LogType = result == .success ? .end : .fatalError
            GZLog.log(msg, type: logType)
            if result == .failed {
                return false
            }
        }
        
        guard GZShellExecute.execute(["pre-commit install"]).1 == .success else {
            GZLog.log("pre-commit install failed", type: .fatalError)
            return false
        }
        
        GZLog.log(" ...................所有工具都安装成功😁😁😁 ", type: .end)
        return true
    }
}

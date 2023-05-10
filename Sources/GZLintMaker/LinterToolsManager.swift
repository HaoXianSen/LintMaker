//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/1/30.
//

import Foundation

/// 检查lint 安装工具
struct LinterToolsManager {
    
    typealias CheckResult = (success: Bool, output: String)
    
    
    /// 检查lint 相关工具
    /// @discuss 检查包括homebrew、privte-tap、Objective-CLint、 swiftLint 并且尝试主动安装， 如果安装失败，可能是网络等因素
    /// 造成需要进一步检查
    /// - Returns: 返回是否都安装成功
    @discardableResult
    static func installTools() -> Bool {
        let animation = WaitingAnimation()
        animation.prefix = "正在检查所有lint工具..."
        DispatchQueue.global().async {
            animation.begin()
        }
        
        var output: [String] = []
        
        let homeBrewResult = self.checkHomebrew()
        if homeBrewResult.0 == true {
            output.append(homeBrewResult.1)
        } else {
            animation.end()
            printError(homeBrewResult.1)
            return false
        }
        
        let brewTapResult = self.checkBrewTap()
        if brewTapResult.0 == true {
            output.append(brewTapResult.1)
        } else {
            animation.end()
            printError(brewTapResult.1)
            return false
        }
        
        let ocLintResult = self.checkObjectiveCLintTool()
        if ocLintResult.0 == true {
            output.append(ocLintResult.1)
        } else {
            animation.end()
            printError(ocLintResult.1)
            return false
        }
        
        let swiftLintResult = self.checkSwiftLintTool()
        if swiftLintResult.0 == true {
            output.append(swiftLintResult.1)
        } else {
            animation.end()
            printError(swiftLintResult.1)
            return false
        }
        
        animation.end()
        self.printAllMessage(output)
        
        queuePrint(" ...................所有工具都安装成功， pre-commit 验证开始生效，快去试试git commit 吧😁😁😁 ")
        return true
    }
    
    
    /// 移除Objective-CLint 和 swiftLint
    /// - Returns: 是否全部安装成功
    @discardableResult
    static func uninstallTools() -> Bool {
        var outputs: [String] = []
        let uninstallObjectiveCLintResult = self.uninstallObjectiveCLintTool()
        let uninstallSwiftLintResult = self.uninstallSwiftLintTool()
        outputs.append(uninstallObjectiveCLintResult.1)
        outputs.append(uninstallSwiftLintResult.1)
        self.printAllMessage(outputs)
        return uninstallObjectiveCLintResult.0 && uninstallSwiftLintResult.0
    }
    
    private static func printAllMessage(_ outputs: [String]) {
        outputs.forEach { string in
            queuePrint(string)
        }
    }
}

//MARK: - install
extension LinterToolsManager {
    /// @description 检查homebrew是否安装 | 安装homebrew
    /// @discuss 如果已经安装homebrew则直接返回， 如果未安装则会自动安装homebrew
    /// @return (_ success: Bool, _ output: String)
    fileprivate static func checkHomebrew() -> CheckResult {
        /// homebrew
        if scriptExecute(["brew -v"]).0 == .success {
            return (true, "homebrew 已经安装")
        } else {
            let result = scriptExecute(["-c", "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"]).0
            let msg = result == .success ? "homebrew installed 🍺🍺🍺 /n" : "homebrew install failed😭"
            return (result == .success, msg)
        }
    }
    
    /// @description 安装homebrew tap
    /// @discuss 安装 haoxiansen/homebrew-private 或者直接更新
    /// @return (_ success: Bool, _ output: String)
    fileprivate static func checkBrewTap() -> CheckResult {
        let privateHomebrewResult = scriptExecute(["brew tap haoxiansen/homebrew-private https://github.com/haoxiansen/homebrew-private"])
        let msg = privateHomebrewResult.status == .failed ? "安装haoxiansen/homebrew-private 失败， 原因：\(privateHomebrewResult.stdout.isEmpty ? privateHomebrewResult.stderr : privateHomebrewResult.stdout)" : "haoxiansen/homebrew-private 安装完成"
        return (privateHomebrewResult.status == .success, msg)
    }
    
    /// @description 安装Objective-CLint
    /// @discuss 主动安装最新版本的 Objective-CLint
    /// @return (_ success: Bool, _ output: String)
    fileprivate static func checkObjectiveCLintTool() -> CheckResult {
        let objectiveCLintResult = scriptExecute(["brew install Objective-CLint"])
        let msg = objectiveCLintResult.status == .failed ? "安装ObjectiveC-Lint失败， 原因：\(objectiveCLintResult.stdout.isEmpty ? objectiveCLintResult.stderr : objectiveCLintResult.stdout)" : "ObjectiveC-Lint 安装完成"
        return (objectiveCLintResult.status == .success, msg)
    }
    
    /// @description 安装swiftLint
    /// @discuss 主动安装最新版本的 swiftLint
    /// @return (_ success: Bool, _ output: String)
    fileprivate static func checkSwiftLintTool() -> CheckResult {
        let objectiveCLintResult = scriptExecute(["brew install swiftLint"])
        let msg = objectiveCLintResult.status == .failed ? "安装swiftLint失败， 原因：\(objectiveCLintResult.stdout.isEmpty ? objectiveCLintResult.stderr : objectiveCLintResult.stdout)" : "swiftLint 安装完成"
        return (objectiveCLintResult.status == .success, msg)
    }
}

//MARK: - uninstall
extension LinterToolsManager {
    
    /// @description 移除Objective-CLint
    /// @return (_ success: Bool, _ output: String)
    fileprivate static func uninstallObjectiveCLintTool() -> CheckResult {
        let objectiveCLintResult = scriptExecute(["brew uninstall Objective-CLint"])
        let msg = objectiveCLintResult.status == .failed ? "移除ObjectiveC-Lint失败， 原因：\(objectiveCLintResult.stdout.isEmpty ? objectiveCLintResult.stderr : objectiveCLintResult.stdout)" : "ObjectiveC-Lint 移除完成"
        return (objectiveCLintResult.status == .success, msg)
    }
    
    /// @description 移除swiftLint
    /// @return (_ success: Bool, _ output: String)
    fileprivate static func uninstallSwiftLintTool() -> CheckResult {
        let objectiveCLintResult = scriptExecute(["brew uninstall swiftLint"])
        let msg = objectiveCLintResult.status == .failed ? "移除swiftLint失败， 原因：\(objectiveCLintResult.stdout.isEmpty ? objectiveCLintResult.stderr : objectiveCLintResult.stdout)" : "swiftLint 移除完成"
        return (objectiveCLintResult.status == .success, msg)
    }
}

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
    /// - 检查包括homebrew、privte-tap、Objective-CLint、 swiftLint 并且尝试主动安装， 如果安装失败，可能是网络等因素
    /// 造成需要进一步检查
    /// - Returns: 返回是否都安装成功
    @discardableResult
    static func installTools() -> Bool {
        mPrint("正在检查所有lint工具...")
        
        var output: [String] = []
        var result = true
        
        let homeBrewResult = self.checkHomebrew()
        if homeBrewResult.success == true {
            output.append(homeBrewResult.output)
        } else {
            printError(homeBrewResult.output)
            result = false
        }
        
        let brewTapResult = self.checkBrewTap()
        if brewTapResult.success == true {
            output.append(brewTapResult.output)
        } else {
            printError(brewTapResult.output)
            result = false
        }
        
        let coreUtilsResult = self.checkCoreUtils()
        if coreUtilsResult.success == true {
            output.append(coreUtilsResult.output)
        } else {
            printError(coreUtilsResult.output)
            result = false
        }
        
        let python3Result = self.checkPython3()
        if python3Result.success == true {
            output.append(python3Result.output)
        } else {
            printError(python3Result.output)
            result = false
        }
        
        let ocLintResult = self.checkObjectiveCLintTool()
        if ocLintResult.success == true {
            output.append(ocLintResult.output)
        } else {
            printError(ocLintResult.output)
            result = false
        }
        
        let swiftLintResult = self.checkSwiftLintTool()
        if swiftLintResult.success == true {
            output.append(swiftLintResult.output)
        } else {
            printError(swiftLintResult.output)
            result = false
        }
        
        self.printAllMessage(output)
        
        if result {
            mPrint("所有工具都安装成功， code lint生效，快去git commit 试试吧! ", textColor: greenForegroundColor)
        }
        return result
    }
    
    /// 移除Objective-CLint 和 swiftLint
    /// - Returns: 是否全部安装成功
    @discardableResult
    static func uninstallTools() -> Bool {
        mPrint("uninstall lint tools ...")
        
        var returnResult = true
        var outputs: [String] = []
        let uninstallObjectiveCLintResult = self.uninstallObjectiveCLintTool()
        let uninstallSwiftLintResult = self.uninstallSwiftLintTool()
        if uninstallObjectiveCLintResult.success {
            outputs.append(uninstallObjectiveCLintResult.1)
        } else {
            printError(uninstallObjectiveCLintResult.output)
            returnResult = false
        }
        
        if uninstallSwiftLintResult.success {
            outputs.append(uninstallSwiftLintResult.1)
        } else {
            printError(uninstallSwiftLintResult.output)
            returnResult = false
        }
        
        self.printAllMessage(outputs)
        
        return returnResult
    }
    
    /// 更新brew 以及 objc-lint swift lint
    /// - Returns: 是否更新成功
    @discardableResult
    static func updateTools() -> Bool {
        mPrint("update lint tool...")
        let result = update()
        if result.success == true {
            printInfo("update success")
        } else {
            printError("update failed, error: \(result.output)")
        }
        return result.0
    }
    
    private static func printAllMessage(_ outputs: [String]) {
        outputs.forEach { string in
            printInfo(string)
        }
    }
}

// MARK: - install
extension LinterToolsManager {
    /// 检查homebrew是否安装 | 安装homebrew
    /// - 如果已经安装homebrew则直接返回， 如果未安装则会自动安装homebrew
    /// - Returns: (_ success: Bool, _ output: String)
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
    
    /// 安装homebrew tap
    /// - 安装 haoxiansen/homebrew-private 或者直接更新
    /// - Returns: (_ success: Bool, _ output: String)
    fileprivate static func checkBrewTap() -> CheckResult {
        let privateHomebrewResult = scriptExecute(["brew tap haoxiansen/private"])
        let msg = privateHomebrewResult.status == .failed ? "安装haoxiansen/private 失败， 原因：\(privateHomebrewResult.stdout)" : "brew tap haoxiansen/private 安装完成"
        return (privateHomebrewResult.status == .success, msg)
    }
    
    /// 安装Objective-CLint
    /// - 主动安装最新版本的 Objective-CLint
    /// - Returns: (_ success: Bool, _ output: String)
    fileprivate static func checkObjectiveCLintTool() -> CheckResult {
        let objectiveCLintResult = scriptExecute(["brew update && brew install objc-lint && brew upgrade objc-lint"])
        let msg = objectiveCLintResult.status == .failed ? "安装objc-lint失败， 原因：\(objectiveCLintResult.stdout)" : "objc-lint 安装完成"
        return (objectiveCLintResult.status == .success, msg)
    }
    
    /// 安装swiftLint
    /// - 主动安装最新版本的 swiftLint
    /// - Returns: (_ success: Bool, _ output: String)
    fileprivate static func checkSwiftLintTool() -> CheckResult {
        let objectiveCLintResult = scriptExecute(["brew install swiftLint && brew upgrade swiftlint"])
        let msg = objectiveCLintResult.status == .failed ? "安装swiftLint失败， 原因：\(objectiveCLintResult.stdout)" : "swiftLint 安装完成"
        return (objectiveCLintResult.status == .success, msg)
    }
    
    /// 安装coreutils用来实现脚本执行时长统计，主要用到gdate
    /// - 因为macOS 本身date 命令的限制，无法统计到毫秒或者更加精确的时间，所以采用gdate实现
    /// - Returns: (_ success: Bool, _ output: String)
    fileprivate static func checkCoreUtils() -> CheckResult {
        let coreUtilsResult = scriptExecute(["brew install coreutils"])
        let msg = coreUtilsResult.status == .failed ? "安装coreutils失败， 原因：\(coreUtilsResult.stdout)" : "coreutils 安装完成"
        return (coreUtilsResult.status == .success, msg)
    }
    
    /// 安装python3用来实现脚本执行时长统计
    /// - ObjectiveC-Lint 需要python3执行一些脚本
    /// - Returns: (_ success: Bool, _ output: String)
    fileprivate static func checkPython3() -> CheckResult {
        let coreUtilsResult = scriptExecute(["brew install python3"])
        let msg = coreUtilsResult.status == .failed ? "安装python3失败， 原因：\(coreUtilsResult.stdout)" : "安装python3 安装完成"
        return (coreUtilsResult.status == .success, msg)
    }
}

// MARK: - uninstall
extension LinterToolsManager {
    
    /// @description 移除Objective-CLint
    /// @return (_ success: Bool, _ output: String)
    fileprivate static func uninstallObjectiveCLintTool() -> CheckResult {
        let objectiveCLintResult = scriptExecute(["brew uninstall objc-lint"])
        let msg = objectiveCLintResult.status == .failed ? "移除objc-lint失败， 原因：\(objectiveCLintResult.stdout)" : "objc-lint 移除完成"
        return (objectiveCLintResult.status == .success, msg)
    }
    
    /// @description 移除swiftLint
    /// @return (_ success: Bool, _ output: String)
    fileprivate static func uninstallSwiftLintTool() -> CheckResult {
        let objectiveCLintResult = scriptExecute(["brew uninstall swiftlint"])
        let msg = objectiveCLintResult.status == .failed ? "移除swiftLint失败， 原因：\(objectiveCLintResult.stdout)" : "swiftLint 移除完成"
        return (objectiveCLintResult.status == .success, msg)
    }
}

extension LinterToolsManager {
    
    fileprivate static func update() -> CheckResult {
        let result = scriptExecute(["brew update && brew upgrade objc-lint && brew upgrade swiftlint"])
        let msg = result.status == .failed ? "更新lint工具失败， 原因：\(result.stdout)" : "更新lint工具成功"
        return (result.status == .success, msg)
    }
}

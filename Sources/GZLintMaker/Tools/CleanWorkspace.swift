//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/6/7.
//

import Foundation

let clangFileName = ".clang-format"
let precommitYamlFile = ".pre-commit-config.yaml"
let precommitHookScriptPath = ".git/hooks/pre-commit"
let precommitHookScriptFile = "pre-commit"
let swiftLintFile = ".swiftlint.yml"

struct CleanWorkspace {
    static func run(_ currentDirectory: String) {
        cleanWorkSpace(currentDirectory: currentDirectory)
    }
    
    private static func cleanWorkSpace(currentDirectory: String) {
        mPrint("Clean workspace...")
        
        let trimingCurrentDirectory = currentDirectory.replacingOccurrences(of: "\n", with: "")
        let clangPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(clangFileName).path
        let preCommitYamlPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(precommitYamlFile).path
        let preCommitHookScriptPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(precommitHookScriptPath).path
        let swiftLintPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(swiftLintFile).path
       
        removeItem(for: clangPath, itemName: ".clang-format")
        
        removeItem(for: swiftLintPath, itemName: ".swiftlint")
        
        removeItem(for: preCommitYamlPath, itemName: ".pre-commit.yaml")
        
        removeItem(for: preCommitHookScriptPath, itemName: "pre-commit hook script")
        
        printInfo("Clean complete")
    }
    
    private static func removeItem(for path: String, itemName: String) {
        
        let manager = FileManager.default
        var isDirectory: ObjCBool = ObjCBool(false)
        
        if manager.fileExists(atPath: path, isDirectory: &isDirectory) == false {
            printInfo("\(itemName) Skiped")
            return
        }
        
        do {
            try manager.removeItem(atPath: path)
        } catch let error as NSError {
            printFatalError("clean\(itemName) failed， reason：\(error.localizedFailureReason ?? "unkown")")
        } catch {
            printFatalError("clean\(itemName) failed， reason：unkown")
        }
        
        printInfo("cleaned \(itemName)...")
    }
}

import ArgumentParser
import Foundation
import OSLog

let clangFileName = ".clang-format"
let precommitYamlFile = ".pre-commit-config.yaml"
let precommitHookScriptPath = ".git/hooks/pre-commit"
let precommitHookScriptFile = "pre-commit"
let swiftLintFile = ".swiftlint.yml"

@main
struct LintMaker: AsyncParsableCommand {
    
    @Flag(name: .long, help: "install all in current workspace")
    var install: Bool = false
    
    @Flag(name: .long, help: "clean current workspace, default 'false'")
    var clean: Bool = false
    
    @Flag(name: .long, help: "uninstall linter tools in current workspace, default 'false'")
    var uninstall: Bool = false
    
    @Option(name: .shortAndLong, help: "Please input a workspace path")
    var projectPath: String?
    
    @Option(name: .shortAndLong, help: "Please input a accessible url, like https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git, contains .clang-format .swiftlint.yml")
    var configureGitPath: String = "https://gitlab.corp.youdao.com/hikari/app/ios/gzlint.git"
    
    // 1. clone 文件夹到当前目录或者给定目录
    // 2 cp 相关文件到当前目录或者给定目录
    @available(macOS 10.15.0, *)
    func run() async throws {
        // 获取项目工作目录
        let workspace = self.projectPath != nil ? self.projectPath : scriptExecute(["pwd"]).1
        
        guard let path = workspace else {
            printFatalError("Get current execute directory failed...")
        }
        
        // 清理当前目录空间
        guard isCleanOrUninstall(path) == false else {
            return
        }
        
        // 下载Config 文件
        downloadFileAndCopy(with: path)
        
        // 安装lint 工具
        LinterToolsManager.installTools()
        
    }
    
    private func isCleanOrUninstall(_ workspace: String) -> Bool {
        var result = false
        if clean {
            cleanWorkSpace(currentDirectory: workspace)
            result = true
        }
        if uninstall {
            LinterToolsManager.uninstallTools()
            result = true
        }
        return result
    }
}

// MARK: - 清理工作空间
extension LintMaker {
    private func cleanWorkSpace(currentDirectory: String) {
        mPrint("Clean workspace...")
        
        let lintRespository = URL(string: configureGitPath)?.deletingPathExtension().lastPathComponent ?? "gzlint"
        let trimingCurrentDirectory = currentDirectory.replacingOccurrences(of: "\n", with: "")
        let lintRespositoryPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(lintRespository).path
        let clangPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(clangFileName).path
        let preCommitYamlPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(precommitYamlFile).path
        let preCommitHookScriptPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(precommitHookScriptPath).path
        let swiftLintPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(swiftLintFile).path
        
        removeItem(for: lintRespositoryPath, itemName: "\(lintRespository)")
       
        removeItem(for: clangPath, itemName: ".clang-format")
        
        removeItem(for: swiftLintPath, itemName: ".swiftlint")
        
        removeItem(for: preCommitYamlPath, itemName: ".pre-commit.yaml")
        
        removeItem(for: preCommitHookScriptPath, itemName: "pre-commit hook script")
        
        printInfo("Clean complete")
    }
    
    private func removeItem(for path: String, itemName: String) {
        
        let manager = FileManager.default
        var isDirectory: ObjCBool = ObjCBool(false)
        
        if manager.fileExists(atPath: path, isDirectory: &isDirectory) == false {
            printInfo("\(itemName) Skiped")
            return
        }
        
        do {
            try manager.removeItem(atPath: path)
        } catch let error as NSError {
            printFatalError("[error] clean\(itemName) failed， reason：\(error.localizedFailureReason ?? "unkown")")
        } catch {
            printFatalError("[error] clean\(itemName) failed， reason：unkown")
        }
        
        printInfo("cleaned \(itemName)...")
    }
}

// MARK: - 下载配置文件 & 移动到工作空间根目录
extension LintMaker {
    private func downloadFileAndCopy(with workspace: String) {
        
        guard let downloadPath = URL(string: self.configureGitPath) else {
            printFatalError("[error] Configuration files download failed，please check --configure-git-path param")
        }
        
        cleanWorkSpace(currentDirectory: workspace)
        
        mPrint("Downloading Configuration file...")
        
        let result = scriptExecute(["git clone \(downloadPath)"])
        
        guard result.0 == .success else {
            printFatalError("[error] Download failed，please check：\(downloadPath)")
        }
        
        printInfo("Download completed")
        
        mPrint("Moving configuration files to workspace...")
        
        let trimingWorkspacePath = workspace.replacingOccurrences(of: "\n", with: "")
        let lastPathComponent = downloadPath.deletingPathExtension().lastPathComponent
        let configurationFilePath = URL(fileURLWithPath: trimingWorkspacePath).appendingPathComponent(lastPathComponent).path
        // copy 资源到目录，完事删除远程目录
        guard FileManager.default.fileExists(atPath: configurationFilePath) == true else {
            return
        }
        
        do {
            try FileManager.default.moveItem(atPath: "\(configurationFilePath)/\(clangFileName)", toPath: "\(trimingWorkspacePath)/\(clangFileName)")
            try FileManager.default.moveItem(atPath: "\(configurationFilePath)/\(swiftLintFile)", toPath: "\(trimingWorkspacePath)/\(swiftLintFile)")
            try FileManager.default.moveItem(atPath: "\(configurationFilePath)/\(precommitHookScriptFile)", toPath: "\(trimingWorkspacePath)/\(precommitHookScriptPath)")
        } catch let error as NSError {
            printFatalError("[error] Moving failed (reason：\(error))")
        } catch {
            printFatalError("[error] Moving failed (reason：未知)")
        }
        
        do {
            try FileManager.default.removeItem(atPath: configurationFilePath)
        } catch {
            printError("[error] Moving failed \(configurationFilePath) failed，please manual delete")
        }
        
        printInfo("Moving success!")
    }
}

import ArgumentParser
import Foundation
import OSLog

let CLANG_FILE_NAME = ".clang-format"
let PRECOMMIT_YAML_FILE = ".pre-commit-config.yaml"
let PRECOMMIT_HOOK_SCRIPT_PATH = ".git/hooks/pre-commit"
let PRECOMMIT_HOOK_SCRIPT_FILE = "pre-commit"
let SWIFT_LINT_FIEL = ".swiftlint.yml"

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

//MARK: - 清理工作空间
extension LintMaker {
    private func cleanWorkSpace(currentDirectory: String) {
        queuePrint("开始清理当前工作空间...")
        
        let lintRespository = URL(string: configureGitPath)?.deletingPathExtension().lastPathComponent ?? "gzlint"
        let trimingCurrentDirectory = currentDirectory.replacingOccurrences(of: "\n", with: "")
        let lintRespositoryPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(lintRespository).path
        let clangPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(CLANG_FILE_NAME).path
        let preCommitYamlPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(PRECOMMIT_YAML_FILE).path
        let preCommitHookScriptPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(PRECOMMIT_HOOK_SCRIPT_PATH).path
        let swiftLintPath = URL(fileURLWithPath: trimingCurrentDirectory).appendingPathComponent(SWIFT_LINT_FIEL).path
        
        removeItem(for: lintRespositoryPath, itemName: "\(lintRespository)目录")
       
        removeItem(for: clangPath, itemName: ".clang-format")
        
        removeItem(for: swiftLintPath, itemName: ".swiftlint")
        
        removeItem(for: preCommitYamlPath, itemName: ".pre-commit.yaml")
        
        removeItem(for: preCommitHookScriptPath, itemName: "pre-commit hook script")
        
        
        queuePrint("清理完成")
    }
    
    private func removeItem(for path: String, itemName: String) {
        
        let fm = FileManager.default
        var isDirectory: ObjCBool = ObjCBool(false)
        
        if fm.fileExists(atPath: path, isDirectory: &isDirectory) == false {
            printError("跳过 \(itemName) 清理")
            return
        }
        
        queuePrint("正在清理 \(itemName)...")
        do {
            try fm.removeItem(atPath: path)
        } catch let error as NSError {
            printFatalError("清理 \(itemName) 失败， 原因：\(error.localizedFailureReason ?? "未知原因")")
        } catch {
            printFatalError("清理 \(itemName) 失败， 原因：未知原因")
        }
    }
}

//MARK: - 下载配置文件 & 移动到工作空间根目录
extension LintMaker {
    private func downloadFileAndCopy(with workspace: String) {
        
        guard let downloadPath = URL(string: self.configureGitPath) else {
            printFatalError("配置文件下载错误，请检查--configure-git-path 传入参数是否正确")
        }
        
        cleanWorkSpace(currentDirectory: workspace)
        
        queuePrint("正在下载远程配置文件...")
        
        let result = scriptExecute(["git clone \(downloadPath)"])
        
        guard result.0 == .success else {
            printFatalError("Download failed，please check：\(downloadPath)")
        }
        
        queuePrint("配置文件下载完成")
        
        queuePrint("移动配置文件到当前工作空间...")
        
        let trimingWorkspacePath = workspace.replacingOccurrences(of: "\n", with: "")
        let lastPathComponent = downloadPath.deletingPathExtension().lastPathComponent
        let configurationFilePath = URL(fileURLWithPath: trimingWorkspacePath).appendingPathComponent(lastPathComponent).path
        // copy 资源到目录，完事删除远程目录
        guard FileManager.default.fileExists(atPath: configurationFilePath) == true else {
            return
        }
        
        do {
            try FileManager.default.moveItem(atPath: "\(configurationFilePath)/\(CLANG_FILE_NAME)", toPath: "\(trimingWorkspacePath)/\(CLANG_FILE_NAME)")
            try FileManager.default.moveItem(atPath: "\(configurationFilePath)/\(SWIFT_LINT_FIEL)", toPath: "\(trimingWorkspacePath)/\(SWIFT_LINT_FIEL)")
            try FileManager.default.moveItem(atPath: "\(configurationFilePath)/\(PRECOMMIT_HOOK_SCRIPT_FILE)", toPath: "\(trimingWorkspacePath)/\(PRECOMMIT_HOOK_SCRIPT_PATH)")
        } catch let error as NSError {
            printFatalError("移动配置文件失败 ...(reason：\(error))")
        } catch {
            printFatalError("移动配置文件失败 ...(reason：未知)")
        }
        
        
        do {
            try FileManager.default.removeItem(atPath: configurationFilePath)
        } catch {
            printError("删除远程配置文件目录失败，请手动删除")
        }
        
        queuePrint("移动所有配置文件成功!")
    }
}

import ArgumentParser
import Foundation

@main
struct LintMaker: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        let subcommands: [ParsableCommand.Type] = [InstallSubCommand.self, CleanCommand.self, UpdateCommand.self, UninstallCommand.self]
        let commandConfiguration = CommandConfiguration(commandName: "lintmaker", version: "1.0.0", subcommands: subcommands, defaultSubcommand: InstallSubCommand.self)
        return commandConfiguration
    }
}

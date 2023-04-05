//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PackagePlugin

@main
struct GitTagPlugin: BuildToolPlugin {
    static func git(_ args: String...) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = Array(args)

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        return String(decoding: outputData, as: UTF8.self)
    }

    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let fileVersion = context.pluginWorkDirectory.appending("Version.swift")
        let tag = try Self.git("--git-dir", "\(target.directory)/../../.git", "describe", "--tags")
        return [
            .buildCommand(
                displayName: "[BUILD COMMAND] Retrieve the current git tag",
                executable: try context.tool(named: "GitTagPluginExec").path,
                arguments: [tag, fileVersion],
                outputFiles: [fileVersion]
            )
        ]
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PackagePlugin

@main
struct PackageInfoPlugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        [
            .prebuildCommand(
                displayName: "Provide package information as a generated Swift file",
                executable: try context.tool(named: "PackageInfo").path,
                arguments: [
                    "\(target.directory.appending("../.."))",
                    "\(context.pluginWorkDirectory)"
                ],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
}

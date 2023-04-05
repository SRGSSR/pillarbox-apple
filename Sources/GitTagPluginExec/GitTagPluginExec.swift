//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@main
@available(macOS 13.0.0, *)
enum GitTagPluginExec {
    static func main() async throws {
        assert(CommandLine.arguments.count == 3, "❗️ The tag version and the output file are required ❗️")

        let tagVersion = CommandLine.arguments[1]
        let fileVersion = URL(filePath: CommandLine.arguments[2])

        let code = """
        enum Version {
            static let gitTag = "\("\(tagVersion)".trimmingCharacters(in: .whitespacesAndNewlines))"
        }
        """

        guard let data = code.data(using: .utf8) else { return }
        try data.write(to: fileVersion, options: .atomic)
    }
}

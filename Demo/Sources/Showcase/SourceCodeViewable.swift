//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

enum Github {
    static func baseUrl() -> URL {
        var url = URL("github://github.com")
        if !UIApplication.shared.canOpenURL(url) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.scheme = "https"
            url = components.url!
        }
        return url
    }
}

private struct SourceCodeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("GitHub")
            }
        }
        .tint(.accentColor)
    }
}

protocol SourceCodeViewable {
    static var filePath: String { get }
}

extension View {
    @ViewBuilder
    func sourceCode<T>(of objectType: T.Type) -> some View where T: SourceCodeViewable {
#if os(iOS)
        if let url = gitHubUrl(for: objectType) {
            swipeActions {
                SourceCodeButton {
                    UIApplication.shared.open(url)
                }
            }
        }
        else {
            self
        }
#else
        self
#endif
    }

    private func gitHubUrl<T>(for objectType: T.Type) -> URL? where T: SourceCodeViewable {
        let separator = "/Demo/"
        guard let relativePath = objectType.filePath.split(separator: separator).last else { return nil }
        return Github.baseUrl()
            .appending(path: "SRGSSR/pillarbox-apple/blob")
            .appending(component: Player.version)
            .appending(path: separator)
            .appending(path: relativePath)
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct SourceCodeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("GitHub")
            }
        }
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
        var url = URL("github://github.com/SRGSSR/pillarbox-apple/blob/main")
            .appending(path: separator)
            .appending(path: relativePath)
        if !UIApplication.shared.canOpenURL(url) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.scheme = "https"
            url = components.url!
        }
        return url
    }
}

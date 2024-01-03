//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

enum GitHub {
    enum Link {
        case android
        case apple
        case documentation
        case project
        case sourceCode(_ path: String)
        case web

        var url: URL {
            switch self {
            case .android:
                baseUrl().appending(path: "srgssr/pillarbox-android")
            case .apple:
                baseUrl().appending(path: "srgssr/pillarbox-apple")
            case .documentation:
                baseUrl().appending(path: "srgssr/pillarbox-documentation")
            case .project:
                baseUrl().appending(path: "orgs/SRGSSR/projects/9")
            case let .sourceCode(path):
                baseUrl()
                    .appending(path: "SRGSSR/pillarbox-apple/blob")
                    .appending(component: Player.version)
                    .appending(path: path)
            case .web:
                baseUrl().appending(path: "srgssr/pillarbox-web")
            }
        }
    }

    private static func baseUrl() -> URL {
        var url = URL("github://github.com")
        if !UIApplication.shared.canOpenURL(url) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.scheme = "https"
            url = components.url!
        }
        return url
    }

    static func open(_ link: Link) {
        UIApplication.shared.open(link.url)
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
        return GitHub.Link.sourceCode(separator + relativePath).url
    }
}

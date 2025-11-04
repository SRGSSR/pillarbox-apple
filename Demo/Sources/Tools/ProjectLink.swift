//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import UIKit
import PillarboxPlayer

enum ProjectLink {
    case android
    case apple
    case documentation
    case project
    case sourceCode(_ path: String)
    case web

    var url: URL {
        switch self {
        case .android:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-android")
        case .apple:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-apple")
        case .documentation:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-documentation")
        case .project:
            Self.gitHubBaseUrl().appending(path: "orgs/SRGSSR/projects/9")
        case let .sourceCode(path):
            Self.gitHubBaseUrl()
                .appending(path: "SRGSSR/pillarbox-apple/blob")
                .appending(component: Player.version)
                .appending(path: path)
        case .web:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-web")
        }
    }

    private static func gitHubBaseUrl() -> URL {
        var url = URL("github://github.com")
        if !UIApplication.shared.canOpenURL(url) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.scheme = "https"
            url = components.url!
        }
        return url
    }
}

extension UIApplication {
    func open(_ link: ProjectLink) {
        open(link.url)
    }
}

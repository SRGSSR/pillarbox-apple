//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer
import UIKit

enum ProjectLink {
    case android
    case apple
    case castor
    case documentation
    case monitoring
    case project
    case sourceCode(_ path: String)
    case swiftPackageIndex
    case web
    case website

    var url: URL {
        switch self {
        case .android:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-android")
        case .apple:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-apple")
        case .castor:
            Self.gitHubBaseUrl().appending(path: "srgssr/castor")
        case .documentation:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-documentation")
        case .monitoring:
            URL(string: "https://grafana.pillarbox.ch")!
        case .project:
            Self.gitHubBaseUrl().appending(path: "orgs/SRGSSR/projects/9")
        case let .sourceCode(path):
            Self.gitHubBaseUrl()
                .appending(path: "SRGSSR/pillarbox-apple/blob")
                .appending(component: Player.version)
                .appending(path: path)
        case .swiftPackageIndex:
            URL(string: "https://swiftpackageindex.com/SRGSSR/pillarbox-apple")!
        case .web:
            Self.gitHubBaseUrl().appending(path: "srgssr/pillarbox-web")
        case .website:
            URL(string: "https://www.pillarbox.ch")!
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

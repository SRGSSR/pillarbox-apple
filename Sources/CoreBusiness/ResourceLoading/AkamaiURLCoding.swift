//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum AkamaiURLCoding {
    private static let schemePrefix = "akamai"
    private static let separator = "+"

    static func encodeUrl(_ url: URL, id: UUID) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme else {
            return url
        }
        components.scheme = "\(schemePrefix)\(separator)\(id.uuidString)\(separator)\(scheme)"
        return components.url ?? url
    }

    static func decodeUrl(_ url: URL, id: UUID) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme else {
            return nil
        }
        let schemeComponents = scheme.components(separatedBy: separator)
        guard schemeComponents.count == 3
                && schemeComponents[0] == schemePrefix
                && schemeComponents[1] == id.uuidString else {
            return nil
        }
        components.scheme = schemeComponents[2]
        return components.url
    }
}

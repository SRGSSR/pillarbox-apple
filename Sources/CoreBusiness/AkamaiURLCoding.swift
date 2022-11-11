//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum AkamaiURLCoding {
    private static let schemePrefix = "akamai"
    private static let separator = "+"

    static func encodeUrl(_ url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme else {
            return url
        }
        components.scheme = "\(schemePrefix)\(separator)\(scheme)"
        return components.url ?? url
    }

    static func decodeUrl(_ url: URL) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme else {
            return nil
        }
        let schemeComponents = scheme.components(separatedBy: separator)
        guard schemeComponents.count == 2 && schemeComponents[0] == schemePrefix else {
            return nil
        }
        components.scheme = schemeComponents[1]
        return components.url
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum URLCoding {
    private static let scheme = "urn"
    private static let parameterName = "urn"

    static func encodeUrl(fromUrn urn: String) -> URL {
        var components = URLComponents(string: "\(scheme)://mediacomposition")!
        components.queryItems = [
            URLQueryItem(name: parameterName, value: urn.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        ]
        return components.url!
    }

    static func decodeUrn(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == scheme,
              let urnQueryItem = components.queryItems?.first(where: { $0.name == parameterName }) else {
            return nil
        }
        return urnQueryItem.value
    }
}

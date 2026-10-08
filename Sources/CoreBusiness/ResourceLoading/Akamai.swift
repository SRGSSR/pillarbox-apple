//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum Akamai {
    private static let schemePrefix = "akamai"
    private static let separator = "+"
    private static let tokenServiceUrl = URL(string: "https://tp.srgssr.ch/akahd/token")!

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

    static func tokenizeUrl(_ url: URL, using session: URLSession) async -> URL {
        guard let requestUrl = tokenRequestUrl(for: url),
              let (data, _) = try? await session.httpData(from: requestUrl),
              let tokenPayload = try? JSONDecoder().decode(TokenPayload.self, from: data),
              let tokenizedUrl = mergeQueryItems(tokenPayload.token.queryItems(), into: url) else {
            return url
        }
        return tokenizedUrl
    }

    private static func acl(for url: URL) -> String {
        url.deletingLastPathComponent().appending(component: "*").path
    }

    private static func tokenRequestUrl(for url: URL) -> URL? {
        guard var components = URLComponents(url: tokenServiceUrl, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "acl", value: acl(for: url))
        ]
        return components.url
    }

    private static func mergeQueryItems(_ queryItems: [URLQueryItem], into url: URL) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        var mergedQueryItems = components.queryItems ?? []
        mergedQueryItems += queryItems
        components.queryItems = mergedQueryItems
        return components.url
    }
}

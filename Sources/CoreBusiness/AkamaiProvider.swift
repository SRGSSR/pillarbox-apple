//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class AkamaiProvider {
    private static let tokenServiceUrl = URL(string: "https://tp.srgssr.ch/akahd/token")!

    private let session = URLSession(configuration: .default)

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
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

    /// Attempt to tokenize the provided URL.
    /// - Parameter url: The URL to tokenize.
    /// - Returns: The tokenized URL or the original URL in case of failure (this URL might still be playable by chance).
    func tokenizeUrl(_ url: URL) -> AnyPublisher<URL, Never> {
        guard let requestUrl = Self.tokenRequestUrl(for: url) else {
            return Just(url)
                .eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: requestUrl)
            .mapHttpErrors()
            .map(\.data)
            .decode(type: TokenPayload.self, decoder: JSONDecoder())
            .map(\.token)
            .tryMap { token in
                guard let tokenizedUrl = Self.mergeQueryItems(token.queryItems(), into: url) else {
                    throw TokenError.malformedParameters
                }
                return tokenizedUrl
            }
            .replaceError(with: url)
            .eraseToAnyPublisher()
    }
}

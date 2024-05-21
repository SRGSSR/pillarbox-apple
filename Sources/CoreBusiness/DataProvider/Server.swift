//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A server environment.
public struct Server {
#if os(iOS)
    private static let vector = "appplay"
#else
    private static let vector = "tvplay"
#endif

    /// Production.
    public static let production = Self(baseUrl: URL(string: "https://il.srgssr.ch")!)

    /// Stage.
    public static let stage = Self(baseUrl: URL(string: "https://il-stage.srgssr.ch")!)

    /// Test.
    public static let test = Self(baseUrl: URL(string: "https://il-test.srgssr.ch")!)

    private let baseUrl: URL
    private let queryItems: [URLQueryItem]

    /// Custom environment.
    ///
    /// - Parameters:
    ///   - baseUrl: The base URL of the server.
    ///   - queryItems: Additional query items to use.
    ///
    /// Useful for servers which can exactly pose as SRG SSR servers and deliver the same playback metadata format and
    /// image scaling capabilities.
    public init(baseUrl: URL, queryItems: [URLQueryItem] = []) {
        self.baseUrl = baseUrl
        self.queryItems = queryItems
    }

    func request(forUrn urn: String) -> URLRequest {
        let url = baseUrl.appending(path: "integrationlayer/2.1/mediaComposition/byUrn/\(urn)")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .init(url: url)
        }
        components.queryItems = queryItems + [
            URLQueryItem(name: "onlyChapters", value: "true"),
            URLQueryItem(name: "vector", value: Self.vector)
        ]
        return .init(url: components.url ?? url)
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        guard var components = URLComponents(
            url: baseUrl.appending(path: "images/"),
            resolvingAgainstBaseURL: false
        ) else {
            return url
        }
        components.queryItems = queryItems + [
            URLQueryItem(name: "imageUrl", value: url.absoluteString),
            URLQueryItem(name: "format", value: "jpg"),
            URLQueryItem(name: "width", value: String(width.rawValue))
        ]
        if let scaledUrl = components.url {
            return scaledUrl
        }
        else {
            return url
        }
    }
}

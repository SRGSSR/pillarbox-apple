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
    public static let production = custom(baseUrl: URL(string: "https://il.srgssr.ch")!)

    /// Stage.
    public static let stage = custom(baseUrl: URL(string: "https://il-stage.srgssr.ch")!)

    /// Test.
    public static let test = custom(baseUrl: URL(string: "https://il-test.srgssr.ch")!)

    private let mediaCompositionBuilder: (String) -> URLRequest
    private let resizedImageUrlBuilder: (URL, ImageWidth) -> URL

    private init(
        mediaCompositionBuilder: @escaping (String) -> URLRequest,
        resizedImageUrlBuilder: @escaping (URL, ImageWidth) -> URL
    ) {
        self.mediaCompositionBuilder = mediaCompositionBuilder
        self.resizedImageUrlBuilder = resizedImageUrlBuilder
    }

    /// Custom environment.
    ///
    /// - Parameters:
    ///   - mediaCompositionBuilder: A closure building a media composition request from a base URL and unique
    ///     identifier (URN).
    ///   - resizedImageUrlBuilder: A closure building a resized URL for an input URL and width.
    ///
    /// Useful for servers which can pose as SRG SSR servers and deliver the same playback metadata format (and
    /// image resizing capabilities if possible).
    public static func custom(
        mediaCompositionBuilder: @escaping (String) -> URLRequest,
        resizedImageUrlBuilder: @escaping (URL, ImageWidth) -> URL
    ) -> Self {
        .init(mediaCompositionBuilder: mediaCompositionBuilder, resizedImageUrlBuilder: resizedImageUrlBuilder)
    }

    /// Custom environment.
    ///
    /// - Parameters:
    ///   - baseUrl: The base URL of the server.
    ///   - queryItems: Additional query items to use.
    ///
    /// Useful for servers which can exactly pose as SRG SSR servers and deliver the same playback metadata format and
    /// image scaling capabilities.
    public static func custom(baseUrl: URL, queryItems: [URLQueryItem] = []) -> Self {
        .custom { urn in
            request(forUrn: urn, baseUrl: baseUrl, queryItems: queryItems)
        } resizedImageUrlBuilder: { url, width in
            resizedImageUrl(url, width: width, baseUrl: baseUrl, queryItems: queryItems)
        }
    }

    private static func request(forUrn urn: String, baseUrl: URL, queryItems: [URLQueryItem]) -> URLRequest {
        let url = baseUrl.appending(path: "integrationlayer/2.1/mediaComposition/byUrn/\(urn)")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .init(url: url)
        }
        components.queryItems = queryItems + [
            URLQueryItem(name: "onlyChapters", value: "true"),
            URLQueryItem(name: "vector", value: vector)
        ]
        return .init(url: components.url ?? url)
    }

    private static func resizedImageUrl(_ url: URL, width: ImageWidth, baseUrl: URL, queryItems: [URLQueryItem]) -> URL {
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

    func request(forUrn urn: String) -> URLRequest {
        mediaCompositionBuilder(urn)
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        resizedImageUrlBuilder(url, width)
    }
}

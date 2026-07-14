//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A server environment.
public enum Server: Codable {
    /// Production.
    case production

    /// Stage.
    case stage

    /// Test.
    case test

    /// Play+ production.
    case playPlusProduction

    /// Play+ integration.
    case playPlusIntegration

    /// Play+ development.
    case playPlusDevelopment

#if os(iOS)
    private static let vector = "appplay"
#else
    private static let vector = "tvplay"
#endif

    private static let supportedMimeTypes = [
        "application/x-mpegURL",
        "video/mpeg",
        "video/mp4",
        "audio/mpeg",
        "audio/mp4; codecs=\"mp4a.40.2\""
    ]

    var id: String {
        switch self {
        case .production:
            return "production"
        case .stage:
            return "stage"
        case .test:
            return "test"
        case .playPlusProduction:
            return "playPlusProduction"
        case .playPlusIntegration:
            return "playPlusIntegration"
        case .playPlusDevelopment:
            return "playPlusDevelopment"
        }
    }

    private var baseUrl: URL {
        switch self {
        case .production:
            URL(string: "https://il.srgssr.ch")!
        case .stage:
            URL(string: "https://il-stage.srgssr.ch")!
        case .test:
            URL(string: "https://il-test.srgssr.ch")!
        case .playPlusProduction:
            URL(string: "https://api.playplus.ch")!
        case .playPlusIntegration:
            URL(string: "https://api.int.playplus.ch")!
        case .playPlusDevelopment:
            URL(string: "https://api.dev.playplus.ch")!
        }
    }

    func mediaCompositionRequest(forUrn urn: String, httpHeaders: [String: String]) -> URLRequest {
        let url = baseUrl.appending(path: "integrationlayer/2.1/mediaComposition/byUrn/\(urn)")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .init(url: url)
        }
        components.queryItems = [
            URLQueryItem(name: "onlyChapters", value: "true"),
            URLQueryItem(name: "vector", value: Self.vector),
            URLQueryItem(name: "streamPlayerCapabilities", value: Self.supportedMimeTypes.joined(separator: ",")),
            URLQueryItem(name: "drmPlayerCapabilities", value: "com.apple.fps")
        ]
        var request = URLRequest(url: components.url ?? url)
        request.allHTTPHeaderFields = httpHeaders
        return request
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        switch self {
        case .production, .stage, .test:
            guard var components = URLComponents(url: baseUrl.appending(path: "images/"), resolvingAgainstBaseURL: false) else {
                return url
            }
            components.queryItems = [
                URLQueryItem(name: "imageUrl", value: url.absoluteString),
                URLQueryItem(name: "format", value: "jpg"),
                URLQueryItem(name: "width", value: String(width.rawValue))
            ]
            return components.url ?? url
        case .playPlusProduction, .playPlusIntegration, .playPlusDevelopment:
            guard var components = URLComponents(url: URL(string: "https://img.playplus.ch")!, resolvingAgainstBaseURL: false) else {
                return url
            }
            components.queryItems = [
                URLQueryItem(name: "src", value: url.absoluteString),
                URLQueryItem(name: "imwidth", value: String(width.rawValue))
            ]
            return components.url ?? url
        }
    }
}

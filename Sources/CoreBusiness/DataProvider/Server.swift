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

    private var resizedImageBaseUrl: URL {
        switch self {
        case .production, .playPlusProduction:
            URL(string: "https://il.srgssr.ch")!
        case .stage, .playPlusIntegration:
            URL(string: "https://il-stage.srgssr.ch")!
        case .test, .playPlusDevelopment:
            URL(string: "https://il-test.srgssr.ch")!
        }
    }

    func mediaCompositionRequest(forUrn urn: String) -> URLRequest {
        let url = baseUrl.appending(path: "integrationlayer/2.1/mediaComposition/byUrn/\(urn)")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .init(url: url)
        }
        components.queryItems = [
            URLQueryItem(name: "onlyChapters", value: "true"),
            URLQueryItem(name: "vector", value: Self.vector)
        ]
        return .init(url: components.url ?? url)
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        guard var components = URLComponents(
            url: resizedImageBaseUrl.appending(path: "images/"),
            resolvingAgainstBaseURL: false
        ) else {
            return url
        }
        components.queryItems = [
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

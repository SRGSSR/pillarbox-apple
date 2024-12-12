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

    /// This API will be removed in a future Pillarbox release. Do not use.
    ///
    /// > Warning: This API will be removed in a future Pillarbox release. Do not use.
    public init(baseUrl: URL, queryItems: [URLQueryItem] = []) {
        // FIXME: This initializer must be made private after SAM replaces the IL. The assertion must be removed at
        //        the same time.
        assert(Bundle.main.allowsReservedInitializer, "This API will be removed in a future Pillarbox release. Do not use.")
        self.baseUrl = baseUrl
        self.queryItems = queryItems
    }

    func mediaCompositionRequest(forUrn urn: String) -> URLRequest {
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

private extension Bundle {
    var allowsReservedInitializer: Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return false }
        return bundleIdentifier.hasPrefix("ch.srgssr.Pillarbox-demo") || bundleIdentifier.hasPrefix("com.apple.dt.xctest.tool")
    }
}

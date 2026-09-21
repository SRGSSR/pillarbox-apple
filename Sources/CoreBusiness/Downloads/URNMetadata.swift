//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Metadata associated with URN-based content.
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct URNMetadata: Codable {
    /// comScore analytics data.
    let analyticsData: [String: String]

    /// Commanders Act analytics data.
    let analyticsMetadata: [String: String]
}

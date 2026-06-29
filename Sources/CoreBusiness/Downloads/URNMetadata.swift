//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct URNMetadata: Codable {
    let analyticsData: [String: String]
    let analyticsMetadata: [String: String]
}

#endif

// swiftlint:enable missing_docs

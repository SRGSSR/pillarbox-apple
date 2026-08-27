//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct URNMetadata: Codable {
    let analyticsData: [String: String]
    let analyticsMetadata: [String: String]
}

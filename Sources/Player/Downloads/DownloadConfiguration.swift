//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct DownloadConfiguration: Codable {
    public static let `default` = Self()

    public var preferredPeakBitRate: Double

    public init(preferredPeakBitRate: Double = 0) {
        self.preferredPeakBitRate = preferredPeakBitRate
    }
}

#endif

// swiftlint:enable missing_docs

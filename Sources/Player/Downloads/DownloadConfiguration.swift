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
    /// TODO: Remove. Just here to avoid having an empty object which otherwise is not persisted as empty object
    ///       by Swift Data, leading to crashes (since `DownloadConfiguration` is not nullable).
    public static let `default` = Self()

    public var preferredPeakBitRate: Double

    public init(preferredPeakBitRate: Double = 0) {
        self.preferredPeakBitRate = preferredPeakBitRate
    }
}

#endif

// swiftlint:enable missing_docs

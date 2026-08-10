//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct DownloadSize {
    public let completed: Int64
    public let total: Int64

    init?(completed: Int64, total: Int64) {
        guard total > 0 else { return nil }
        self.completed = completed.clamped(to: 0...total)
        self.total = total
    }

    init?(total: Int64) {
        self.init(completed: total, total: total)
    }
}

#endif

// swiftlint:enable missing_docs

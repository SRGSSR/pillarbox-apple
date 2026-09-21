//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A download state.
@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public enum DownloadState: Equatable {
    /// Preparing.
    case preparing

    /// Running.
    case running

    /// Suspended.
    case suspended

    /// Completed.
    case completed
}

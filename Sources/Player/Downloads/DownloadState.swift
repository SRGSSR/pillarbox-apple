//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public enum DownloadState: Equatable {
    case preparing
    case running
    case suspended
    case completed
}

#endif

// swiftlint:enable missing_docs

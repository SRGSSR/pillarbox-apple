//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

@_spi(DownloaderPrivate)
public enum DownloadState: Equatable {
    case preparing
    case running
    case suspended
    case completed
    case cancelled
}

// swiftlint:enable missing_docs

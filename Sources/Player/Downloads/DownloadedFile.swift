//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Foundation

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public enum DownloadedFile {
    case unavailable
    case partial(PlayerItem)
    case complete(PlayerItem)
    case failed
}

#endif

// swiftlint:enable missing_docs

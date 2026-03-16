//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public enum DownloadedFile {
    case unavailable
    case partial(URL)
    case complete(URL)
    case failed
}

#endif

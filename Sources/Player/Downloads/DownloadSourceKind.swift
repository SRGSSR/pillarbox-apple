//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@available(tvOS, unavailable)
enum DownloadSourceKind {
    case estimate(Double)
    case task(DownloadSessionTaskProperties)
}

#endif

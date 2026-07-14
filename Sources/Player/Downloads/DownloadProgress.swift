//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@available(tvOS, unavailable)
enum DownloadProgress {
    case estimate(Double)
    case actual(DownloadSessionTaskProperties)

    // Add URL and error here
}

#endif

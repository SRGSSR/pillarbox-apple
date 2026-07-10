//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
enum DownloadSource {
    case estimate(Double)
    case task(DownloadSessionTaskProperties)
}

#endif

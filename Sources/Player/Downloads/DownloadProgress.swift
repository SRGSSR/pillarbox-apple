//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
enum DownloadProgress {
    case estimate(Double)
    case actual(DownloadSessionTaskProperties)
}

#endif

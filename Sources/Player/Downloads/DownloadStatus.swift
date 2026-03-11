//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public enum DownloadStatus: Equatable {
    case running
    case suspended
    case completed(URL)
    case failed
}

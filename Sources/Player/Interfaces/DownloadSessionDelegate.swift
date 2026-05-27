//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@available(tvOS, unavailable)
protocol DownloadSessionDelegate: AnyObject {
    func downloadSessionWillDownloadToLocation(_ location: URL, forId id: String)
    func downloadSessionDidFailWithError(_ error: any Error, forId id: String)
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

protocol DownloadSessionDelegate: AnyObject {
    // TODO: associated type for session?
    func downloadSession(_ session: some DownloadSession, willDownloadToLocation location: URL, forId id: String)
    func downloadSession(_ session: some DownloadSession, didFailWithError error: any Error, forId id: String)
}

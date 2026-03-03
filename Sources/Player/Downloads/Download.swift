//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct Download: Hashable {
    let url: URL
    let state: AVAssetDownloadTask.State

    init(url: URL) {
        self.url = url
        self.state = .running
    }
}

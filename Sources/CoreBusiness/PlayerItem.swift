//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVPlayerItem {
    convenience init(urn: String, environment: Environment = .production) {
        self.init(url: URL(string: "urn")!)
    }
}

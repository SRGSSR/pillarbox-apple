//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Foundation

extension PlayerItem {
    convenience init(url: URL, delay: TimeInterval) {
        let publisher = Just(AVPlayerItem(url: url))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        self.init(publisher: publisher)
    }
}

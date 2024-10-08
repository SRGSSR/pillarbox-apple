//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension Player {
    func currentPlayerItemPublisher() -> AnyPublisher<AVPlayerItem?, Never> {
        queuePublisher.slice(at: \.itemState.item)
    }
}

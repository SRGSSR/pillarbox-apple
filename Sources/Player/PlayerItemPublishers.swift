//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension AVPlayerItem {
    func itemStatePublisher() -> AnyPublisher<ItemState, Never> {
        Publishers.Merge(
            publisher(for: \.status)
                .map { [weak self] status in
                    ItemState.itemState(for: status, error: self?.error)
                },
            NotificationCenter.default.weakPublisher(for: .AVPlayerItemDidPlayToEndTime, object: self)
                .map { _ in .ended }
        )
        .eraseToAnyPublisher()
    }
}

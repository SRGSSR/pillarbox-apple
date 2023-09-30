//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension AVPlayer {
    func itemPropertiesPublisher() -> AnyPublisher<PlayerItemProperties, Never> {
        publisher(for: \.currentItem)
            .map { item in
                guard let item else { return Just(PlayerItemProperties.empty).eraseToAnyPublisher() }
                return item.propertiesPublisher()
            }
            .switchToLatest()
            .prepend(.empty)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func errorPublisher() -> AnyPublisher<Error?, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0?.errorPublisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

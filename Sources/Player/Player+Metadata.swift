//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore

extension Player {
    func currentMetadataPublisher() -> AnyPublisher<CurrentMetadata?, Never> {
        queuePublisher
            .slice(at: \.item)
            .scan(nil) { metadata, item in
                if let item {
                    return CurrentMetadata(item: item)
                }
                else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
}

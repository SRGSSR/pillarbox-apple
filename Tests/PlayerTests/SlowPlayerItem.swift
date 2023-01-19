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
    static func simple(url: URL, delay: TimeInterval) -> Self {
        let publisher = Just(Asset.simple(url: url))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher)
    }
}

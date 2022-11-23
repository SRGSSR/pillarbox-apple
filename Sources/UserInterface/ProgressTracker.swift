//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import Player

public final class ProgressTracker: ObservableObject {
    /// Progress in 0...1
    @Published public var progress: Float = 0
    @Published public var player: Player?

    public var range: ClosedRange<Float> {
        0...1
    }

    private let interval: CMTime

    public init(interval: CMTime) {
        self.interval = interval
    }
}

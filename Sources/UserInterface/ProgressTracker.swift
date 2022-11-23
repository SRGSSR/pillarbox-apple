//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import Player

@MainActor
public final class ProgressTracker: ObservableObject {
    @Published public var player: Player?
    @Published private var _progress: Float?

    public var progress: Float {
        get {
            _progress ?? 0
        }
        set {
            _progress = newValue
        }
    }

    public var range: ClosedRange<Float> {
        _progress != nil ? 0...1 : 0...0
    }

    private let interval: CMTime

    public init(interval: CMTime) {
        self.interval = interval
        $player
            .map { Self.progressPublisher(for: $0) }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$_progress)
    }

    private static func progressPublisher(for player: Player?) -> AnyPublisher<Float?, Never> {
        guard let player else {
            return Just(Optional<Float>.none).eraseToAnyPublisher()
        }
        return Just(Float(0)).eraseToAnyPublisher()
    }
}

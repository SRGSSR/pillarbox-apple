//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Core
import CoreMedia
import SwiftUI

/// An observable object which tracks buffering.
public final class BufferTracker: ObservableObject {
    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// The buffer position.
    ///
    /// Returns a value between 0 and 1 indicating up to where content has been loaded and is available for
    /// playback.
    @Published public private(set) var buffer: Float = .zero

    /// Creates a buffer tracker.
    public init() {
        $player
            .map { player -> AnyPublisher<Float, Never> in
                guard let player else { return Just(0).eraseToAnyPublisher() }
                return player.queuePlayer
                    .currentItemBufferPublisher()
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .receiveOnMainThread()
            .assign(to: &$buffer)
    }
}

public extension View {
    /// Binds a buffer tracker to a player.
    ///
    /// - Parameters:
    ///   - buffer: The buffer tracker to bind.
    ///   - player: The player to observe.
    func bind(_ bufferTracker: BufferTracker, to player: Player?) -> some View {
        onAppear {
            bufferTracker.player = player
        }
        .onChange(of: player) { newValue in
            bufferTracker.player = newValue
        }
    }
}

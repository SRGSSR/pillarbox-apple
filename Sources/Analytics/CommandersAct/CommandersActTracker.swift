//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import Player

/// Stream tracker for Commanders Act.
public final class CommandersActTracker: PlayerItemTracker {
    private var cancellables = Set<AnyCancellable>()

    public init(configuration: Void, metadataPublisher: AnyPublisher<[String: String], Never>) {}

    private static func eventName(for playbackState: PlaybackState) -> String? {
        switch playbackState {
        case .playing:
            return "play"
        case .paused:
            return "pause"
        default:
            return nil
        }
    }

    public func enable(for player: Player) {
        player.$playbackState
            .sink { [weak self] playbackState in
                self?.notify(playbackState: playbackState)
            }
            .store(in: &cancellables)
    }

    private func notify(playbackState: PlaybackState) {
        guard let name = Self.eventName(for: playbackState) else { return }
        Analytics.shared.sendCommandersActStreamingEvent(name: name)
    }

    public func disable() {
        cancellables = []
    }
}

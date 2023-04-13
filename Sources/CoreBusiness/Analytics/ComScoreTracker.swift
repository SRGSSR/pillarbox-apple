//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics
import Combine
import ComScore
import Foundation
import Player

/// Stream tracker for comScore.
public final class ComScoreTracker: PlayerItemTracker {
    private let streamingAnalytics = SCORStreamingAnalytics()
    private var cancellables = Set<AnyCancellable>()

    public init(configuration: Void, metadataPublisher: AnyPublisher<[String: String], Never>) {}

    public func enable(for player: Player) {
        streamingAnalytics.createPlaybackSession()
        streamingAnalytics.setMediaPlayerName("Pillarbox")
        streamingAnalytics.setMediaPlayerVersion(PackageInfo.version)

        player.$playbackState
            .sink { [weak self] playbackState in
                self?.notify(playbackState: playbackState)
            }
            .store(in: &cancellables)
    }

    public func disable() {
        cancellables = []
    }

    private func notify(playbackState: PlaybackState) {
        let metadata = SCORStreamingContentMetadata { builder in
            guard let builder, let testId = Analytics.shared.testId else { return }
            builder.setCustomLabels([Analytics.testIdentifierKey: testId])
        }
        streamingAnalytics.setMetadata(metadata)

        switch playbackState {
        case .playing:
            streamingAnalytics.notifyPlay()
        case .paused:
            streamingAnalytics.notifyPause()
        default:
            break
        }
    }
}

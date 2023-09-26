//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import ComScore
import CoreMedia
import Foundation
import Player
import UIKit

/// A comScore tracker for streaming.
///
/// This tracker implements streaming measurements according to Mediapulse official specifications.
///
/// Analytics have to be properly started for the tracker to collect data, see `Analytics.start(with:)`.
public final class ComScoreTracker: PlayerItemTracker {
    private var streamingAnalytics = SCORStreamingAnalytics()
    private var cancellables = Set<AnyCancellable>()
    @Published private var metadata: Metadata = .empty

    public init(configuration: Void, metadataPublisher: AnyPublisher<Metadata, Never>) {
        metadataPublisher.assign(to: &$metadata)
    }

    public func enable(for player: Player) {
        streamingAnalytics.createPlaybackSession()
        streamingAnalytics.setMediaPlayerName("Pillarbox")
        streamingAnalytics.setMediaPlayerVersion(Player.version)

        $metadata.sink { [weak self] metadata in
            self?.updateMetadata(with: metadata)
        }
        .store(in: &cancellables)

        Publishers.CombineLatest(
            UIApplication.shared.applicationStatePublisher(),
            player.$properties
        )
        .sink { [weak self, weak player] state, properties in
            guard let self, let player else { return }
            notify(
                applicationState: state,
                playbackState: properties.playbackState,
                isSeeking: properties.isSeeking,
                isBuffering: properties.itemProperties.isBuffering,
                player: player
            )
        }
        .store(in: &cancellables)

        player.objectWillChange
            .receive(on: DispatchQueue.main)
            .map { _ in () }
            .prepend(())
            .weakCapture(player)
            .map { $1.effectivePlaybackSpeed }
            .removeDuplicates()
            .sink { [weak self] speed in
                self?.notifyPlaybackSpeedChange(speed: speed)
            }
            .store(in: &cancellables)
    }

    public func disable() {
        cancellables = []
        streamingAnalytics = SCORStreamingAnalytics()
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func notify(applicationState: ApplicationState, playbackState: PlaybackState, isSeeking: Bool, isBuffering: Bool, player: Player) {
        guard !metadata.labels.isEmpty else { return }

        AnalyticsListener.capture(streamingAnalytics.configuration())
        streamingAnalytics.setProperties(for: player, streamType: metadata.streamType)

        guard applicationState == .foreground else {
            streamingAnalytics.notifyEvent(for: .paused, at: player.effectivePlaybackSpeed)
            return
        }

        switch (isSeeking, isBuffering) {
        case (true, true):
            streamingAnalytics.notifySeekStart()
            streamingAnalytics.notifyBufferStart()
        case (true, false):
            streamingAnalytics.notifySeekStart()
            streamingAnalytics.notifyBufferStop()
        case (false, true):
            streamingAnalytics.notifyBufferStart()
        case (false, false):
            streamingAnalytics.notifyBufferStop()
            streamingAnalytics.notifyEvent(for: playbackState, at: player.effectivePlaybackSpeed)
        }
    }

    private func notifyPlaybackSpeedChange(speed: Float) {
        streamingAnalytics.notifyChangePlaybackRate(speed)
    }

    private func updateMetadata(with metadata: Metadata) {
        let builder = SCORStreamingContentMetadataBuilder()
        if let globals = Analytics.shared.comScoreGlobals {
            builder.setCustomLabels(metadata.labels.merging(globals.labels) { _, new in new })
        }
        else {
            builder.setCustomLabels(metadata.labels)
        }
        let contentMetadata = SCORStreamingContentMetadata(builder: builder)
        streamingAnalytics.setMetadata(contentMetadata)
    }
}

public extension ComScoreTracker {
    /// comScore tracker metadata.
    struct Metadata {
        let labels: [String: String]
        let streamType: StreamType

        static var empty: Self {
            .init(labels: [:], streamType: .unknown)
        }

        /// Creates comScore metadata.
        ///
        /// - Parameters:
        ///   - labels: The labels.
        ///   - streamType: The stream type.
        public init(labels: [String: String], streamType: StreamType) {
            self.labels = labels
            self.streamType = streamType
        }
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import ComScore
import CoreMedia
import Player
import UIKit

/// A comScore tracker for streaming.
///
/// This tracker implements streaming measurements according to Mediapulse official specifications.
///
/// Analytics have to be properly started for the tracker to collect data, see `Analytics.start(with:)`.
public final class ComScoreTracker: PlayerItemTracker {
    private var streamingAnalytics = ComScoreStreamingAnalytics()
    private var metadata: [String: String] = [:]
    private var properties: PlayerProperties?
    private weak var player: Player?
    private var cancellables = Set<AnyCancellable>()

    private var applicationState: ApplicationState = .foreground {
        didSet {
            guard let properties else { return }
            updateProperties(with: properties)
        }
    }

    public init(configuration: Void) {}

    public func enable(for player: Player) {
        self.player = player
        streamingAnalytics.createPlaybackSession()
        streamingAnalytics.setMediaPlayerName("Pillarbox")
        streamingAnalytics.setMediaPlayerVersion(Player.version)
        registerApplicationStateNotifications()
    }

    public func updateMetadata(with metadata: [String: String]) {
        let builder = SCORStreamingContentMetadataBuilder()
        if let globals = Analytics.shared.comScoreGlobals {
            builder.setCustomLabels(metadata.merging(globals.labels) { _, new in new })
        }
        else {
            builder.setCustomLabels(metadata)
        }
        let contentMetadata = SCORStreamingContentMetadata(builder: builder)
        streamingAnalytics.setMetadata(contentMetadata)
        self.metadata = metadata
    }

    public func updateProperties(with properties: PlayerProperties) {
        self.properties = properties
        notify(with: properties)
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func notify(with properties: PlayerProperties) {
        guard !metadata.isEmpty, let player else { return }

        AnalyticsListener.capture(streamingAnalytics.configuration())
        streamingAnalytics.setProperties(for: properties, time: player.time, streamType: properties.streamType)

        guard applicationState == .foreground else {
            streamingAnalytics.notifyEvent(for: .paused, at: properties.rate)
            return
        }

        switch (properties.isSeeking, properties.isBuffering) {
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
            streamingAnalytics.notifyEvent(for: properties.playbackState, at: properties.rate)
        }
    }

    public func disable() {
        unregisterApplicationStateNotifications()
        streamingAnalytics = ComScoreStreamingAnalytics()
        player = nil
    }
}

private extension ComScoreTracker {
    enum ApplicationState {
        case foreground
        case background
    }

    func registerApplicationStateNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    func unregisterApplicationStateNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc
    private func didEnterBackground(_ notification: Notification) {
        applicationState = .background
    }

    @objc
    private func didBecomeActive(_ notification: Notification) {
        applicationState = .foreground
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Foundation
import Player

/// A Commanders Act tracker for streaming.
///
/// This tracker implements streaming measurements according to SRG SSR official specifications.
///
/// Analytics have to be properly started for the tracker to collect data, see `Analytics.start(with:)`.
public final class CommandersActTracker: PlayerItemTracker {
    private var cancellables = Set<AnyCancellable>()
    private var streamingAnalytics: CommandersActStreamingAnalytics?
    @Published private var metadata: Metadata = .empty

    public init(configuration: Void, metadataPublisher: AnyPublisher<Metadata, Never>) {
        metadataPublisher.assign(to: &$metadata)
    }

    public func enable(for player: Player) {
        Publishers.CombineLatest(player.$playbackState, player.$isSeeking)
            .map { (playbackState: $0, isSeeking: $1) }
            .weakCapture(player)
            .sink { [weak self] state, player in
                self?.notify(playbackState: state.playbackState, isSeeking: state.isSeeking, player: player)
            }
            .store(in: &cancellables)

        player.$isBuffering
            .sink { [weak self] isBuffering in
                self?.streamingAnalytics?.notify(isBuffering: isBuffering)
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
                self?.streamingAnalytics?.notifyPlaybackSpeed(speed)
            }
            .store(in: &cancellables)
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func notify(playbackState: PlaybackState, isSeeking: Bool, player: Player) {
        if isSeeking {
            streamingAnalytics?.notify(.seek)
        }
        else {
            switch playbackState {
            case .playing:
                guard streamingAnalytics != nil else {
                    streamingAnalytics = CommandersActStreamingAnalytics(streamType: metadata.streamType) { [weak self, weak player] in
                        guard let self, let player else { return nil }
                        return CommandersActStreamingAnalytics.EventData(
                            labels: labels(for: player),
                            time: player.time,
                            range: player.timeRange
                        )
                    }
                    break
                }
                streamingAnalytics?.notify(.play)
            case .paused:
                streamingAnalytics?.notify(.pause)
            case .ended:
                streamingAnalytics?.notify(.eof)
            case .failed:
                streamingAnalytics?.notify(.stop)
            default:
                break
            }
        }
    }

    public func disable() {
        cancellables = []
        streamingAnalytics = nil
    }
}

private extension CommandersActTracker {
    private func volume(for player: Player) -> Int {
        guard !player.isMuted else { return 0 }
        return Int(AVAudioSession.sharedInstance().outputVolume * 100)
    }

    private func bitrate(for player: Player) -> Int {
        guard let event = player.systemPlayer.currentItem?.accessLog()?.events.last else { return 0 }
        return Int(max(event.indicatedBitrate, 0))
    }

    func labels(for player: Player) -> [String: String] {
        metadata.labels.merging([
            "media_player_display": "Pillarbox",
            "media_player_version": PackageInfo.version,
            "media_volume": "\(volume(for: player))"
        ]) { _, new in new }
    }
}

public extension CommandersActTracker {
    /// Commanders Act tracker metadata.
    struct Metadata {
        let labels: [String: String]
        let streamType: StreamType

        static var empty: Self {
            .init(labels: [:], streamType: .unknown)
        }

        /// Creates Commanders Act metadata.
        ///
        /// - Parameters:
        ///   - labels: The labels associated with the content being played.
        ///   - streamType: The stream type.
        public init(labels: [String: String], streamType: StreamType) {
            self.labels = labels
            self.streamType = streamType
        }
    }
}

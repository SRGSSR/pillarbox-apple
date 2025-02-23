//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A type describing properties accessible to tracker implementations.
public struct TrackerProperties {
    private let playerProperties: PlayerProperties

    /// The current time.
    public let time: CMTime

    /// The current date.
    ///
    /// The date is `nil` when no date information is available from the stream.
    public let date: Date?

    /// The current player metrics, if available.
    ///
    /// > Important: Metrics are reset when toggling external playback.
    public let metrics: Metrics?

    init(playerProperties: PlayerProperties, time: CMTime, date: Date?, metrics: Metrics?) {
        self.playerProperties = playerProperties
        self.time = time
        self.date = date
        self.metrics = metrics
    }
}

public extension TrackerProperties {
    /// The time at which the player is currently seeking, if any.
    var seekTime: CMTime? {
        playerProperties.seekTime
    }
}

public extension TrackerProperties {
    /// A Boolean describing whether the player is currently seeking to another position.
    var isSeeking: Bool {
        playerProperties.isSeeking
    }

    /// A Boolean describing whether the player is currently buffering.
    var isBuffering: Bool {
        playerProperties.isBuffering
    }

    /// A Boolean describing whether the player is currently busy (buffering or seeking).
    var isBusy: Bool {
        playerProperties.isBusy
    }

    /// The type of stream currently being played.
    var streamType: StreamType {
        playerProperties.streamType
    }
}

public extension TrackerProperties {
    /// The current media option for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The current option.
    ///
    /// Unlike `selectedMediaOption(for:)` this method provides the currently applied option. This method can
    /// be useful if you need to access the actual selection made by `select(mediaOption:for:)` for `.automatic`
    /// and `.off` options (forced options might be returned where applicable).
    func currentMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        playerProperties.currentMediaOption(for: characteristic)
    }
}

public extension TrackerProperties {
    /// The current presentation size.
    ///
    /// Might be zero for audio content or `nil` when unknown.
    var presentationSize: CGSize? {
        playerProperties.presentationSize
    }

    /// The duration of a chunk for the currently played item.
    ///
    /// Might be `.invalid` when no content is being played or when unknown.
    var chunkDuration: CMTime {
        playerProperties.chunkDuration
    }

    /// The current media type.
    var mediaType: MediaType {
        playerProperties.mediaType
    }

    /// The player playback state.
    var playbackState: PlaybackState {
        playerProperties.playbackState
    }

    /// The player rate.
    var rate: Float {
        playerProperties.rate
    }

    /// A Boolean describing whether the player is currently playing video in external playback mode.
    var isExternalPlaybackActive: Bool {
        playerProperties.isExternalPlaybackActive
    }

    /// A Boolean describing whether the player is currently muted.
    var isMuted: Bool {
        playerProperties.isMuted
    }
}

public extension TrackerProperties {
    /// The time range within which it is possible to seek.
    ///
    /// Returns `.invalid` when the time range is unknown.
    var seekableTimeRange: CMTimeRange {
        playerProperties.seekableTimeRange
    }

    /// The time range which has been loaded.
    ///
    /// Returns `.invalid` when the time range is unknown.
    var loadedTimeRange: CMTimeRange {
        playerProperties.loadedTimeRange
    }

    /// The buffer position.
    ///
    /// Returns a value between 0 and 1 indicating up to where content has been loaded and is available for
    /// playback.
    var buffer: Float {
        playerProperties.buffer
    }
}

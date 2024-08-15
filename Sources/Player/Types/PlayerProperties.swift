//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

/// A type describing player properties.
public struct PlayerProperties: Equatable {
    static let empty = Self(
        coreProperties: .empty,
        timeProperties: .empty,
        isEmpty: true,
        seekTime: nil
    )

    let coreProperties: CoreProperties
    private let timeProperties: TimeProperties
    let isEmpty: Bool

    /// The time at which the player is currently seeking, if any.
    public let seekTime: CMTime?

    init(
        coreProperties: CoreProperties,
        timeProperties: TimeProperties,
        isEmpty: Bool,
        seekTime: CMTime?
    ) {
        self.timeProperties = timeProperties
        self.coreProperties = coreProperties
        self.isEmpty = isEmpty
        self.seekTime = seekTime
    }
}

public extension PlayerProperties {
    /// A Boolean describing whether the player is currently seeking to another position.
    var isSeeking: Bool {
        seekTime != nil
    }

    /// A Boolean describing whether the player is currently buffering.
    var isBuffering: Bool {
        !isEmpty && !timeProperties.isPlaybackLikelyToKeepUp
    }

    /// A Boolean describing whether the player is currently busy (buffering or seeking).
    var isBusy: Bool {
        isBuffering || isSeeking
    }

    /// The type of stream currently being played.
    var streamType: StreamType {
        StreamType(for: seekableTimeRange, duration: coreProperties.duration)
    }
}

public extension PlayerProperties {
    /// The current media option for a characteristic.
    ///
    /// - Parameter characteristic: The characteristic.
    /// - Returns: The current option.
    ///
    /// Unlike `selectedMediaOption(for:)` this method provides the currently applied option. This method can
    /// be useful if you need to access the actual selection made by `select(mediaOption:for:)` for `.automatic`
    /// and `.off` options (forced options might be returned where applicable).
    func currentMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let option = mediaSelectionProperties.selectedOption(for: characteristic) else { return .off }
        return .on(option)
    }
}

// MARK: CoreProperties

public extension PlayerProperties {
    /// The current presentation size.
    ///
    /// Might be zero for audio content or `nil` when unknown.
    var presentationSize: CGSize? {
        coreProperties.presentationSize
    }

    /// The duration of a chunk for the currently played item.
    ///
    /// Might be `.invalid` when no content is being played or when unknown.
    var chunkDuration: CMTime {
        coreProperties.chunkDuration
    }

    /// The current media type.
    var mediaType: MediaType {
        coreProperties.mediaType
    }

    /// The player playback state.
    var playbackState: PlaybackState {
        coreProperties.playbackState
    }

    /// The player rate.
    var rate: Float {
        coreProperties.rate
    }

    /// A Boolean describing whether the player is currently playing video in external playback mode.
    var isExternalPlaybackActive: Bool {
        coreProperties.isExternalPlaybackActive
    }

    /// A Boolean describing whether the player is currently muted.
    var isMuted: Bool {
        coreProperties.isMuted
    }
}

public extension PlayerProperties {
    /// The player time.
    func time() -> CMTime {
        coreProperties.time()
    }

    /// The date corresponding to the player time.
    ///
    /// This date is only returned when available from the stream.
    func date() -> Date? {
        coreProperties.date()
    }

    /// The current player metrics, if available.
    ///
    /// Each call to this function might return different results reflecting the most recent metrics available. The
    /// included ``Metrics/increment`` collates data from the most recent period of playback not interrupted by a
    /// seek or variant switch.
    func metrics() -> Metrics? {
        coreProperties.metrics()
    }
}

extension PlayerProperties {
    var mediaSelectionProperties: MediaSelectionProperties {
        coreProperties.mediaSelectionProperties
    }

    var itemStatus: ItemStatus {
        coreProperties.itemStatus
    }

    var duration: CMTime {
        coreProperties.duration
    }
}

// MARK: TimeProperties

public extension PlayerProperties {
    /// The time range within which it is possible to seek.
    ///
    /// Returns `.invalid` when the time range is unknown.
    var seekableTimeRange: CMTimeRange {
        timeProperties.seekableTimeRange
    }

    /// The time range which has been loaded.
    ///
    /// Returns `.invalid` when the time range is unknown.
    var loadedTimeRange: CMTimeRange {
        timeProperties.loadedTimeRange
    }

    /// The buffer position.
    ///
    /// Returns a value between 0 and 1 indicating up to where content has been loaded and is available for
    /// playback.
    var buffer: Float {
        timeProperties.buffer
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core
import DequeModule
import MediaPlayer
import TimelaneCombine

/// An audio / video player maintaining its items as a double-ended queue (deque).
public final class Player: ObservableObject, Equatable {
    private static weak var currentPlayer: Player?

    /// Current playback state.
    @Published public private(set) var playbackState: PlaybackState = .idle

    /// Current presentation size. Might be zero for audio content or `nil` when unknown.
    @Published public private(set) var presentationSize: CGSize?

    /// Returns whether the player is currently buffering.
    @Published public private(set) var isBuffering = false

    /// Returns whether the player is currently seeking to another position.
    @Published public private(set) var isSeeking = false

    /// The index of the current item in the queue.
    @Published public private(set) var currentIndex: Int?

    /// Duration of a chunk for the currently played item.
    @Published public private(set) var chunkDuration: CMTime = .invalid

    /// Indicates whether the player is currently playing video in external playback mode.
    @Published public private(set) var isExternalPlaybackActive = false

    /// Set whether trackers are enabled or not.
    @Published public var isTrackingEnabled = true

    /// Set whether the audio output of the player is muted.
    @Published public var isMuted = true {
        didSet {
            queuePlayer.isMuted = isMuted
        }
    }

    @Published var _playbackSpeed: PlaybackSpeed = .indefinite
    @Published var currentItem: CurrentItem = .good(nil)
    @Published var storedItems: Deque<PlayerItem>

    @Published private var isActive = false {
        didSet {
            if isActive {
                nowPlayingSession.becomeActiveIfPossible()
                queuePlayer.allowsExternalPlayback = configuration.allowsExternalPlayback
            }
            else {
                queuePlayer.allowsExternalPlayback = false
            }
        }
    }

    @Published private var currentTracker: CurrentTracker?

    /// The player configuration
    public let configuration: PlayerConfiguration

    /// The type of stream currently played.
    public var streamType: StreamType {
        StreamType(for: timeRange, itemDuration: itemDuration)
    }

    /// The current media type.
    public var mediaType: MediaType {
        guard let presentationSize else { return .unknown }
        return presentationSize == .zero ? .audio : .video
    }

    /// The current time.
    public var time: CMTime {
        queuePlayer.currentTime().clamped(to: timeRange)
    }

    /// The available time range or `.invalid` when not known.
    public var timeRange: CMTimeRange {
        queuePlayer.timeRange
    }

    /// Returns whether the player is currently busy (buffering or seeking).
    public var isBusy: Bool {
        isBuffering || isSeeking
    }

    /// The low-level system player. Exposed for specific read-only needs like interfacing with `AVPlayer`-based
    /// 3rd party APIs. Mutating the state of this player directly is not supported and leads to undefined behavior.
    public var systemPlayer: AVPlayer {
        queuePlayer
    }

    /// The current item duration or `.invalid` when not known.
    var itemDuration: CMTime {
        queuePlayer.itemDuration
    }

    let queuePlayer = QueuePlayer()
    let nowPlayingSession: MPNowPlayingSession

    var cancellables = Set<AnyCancellable>()
    var commandRegistrations: [any RemoteCommandRegistrable] = []

    // swiftlint:disable:next private_subject
    var desiredPlaybackSpeedPublisher = PassthroughSubject<Float, Never>()

    /// Create a player with a given item queue.
    /// - Parameters:
    ///   - items: The items to be queued initially.
    ///   - configuration: The configuration to apply to the player.
    public init(items: [PlayerItem] = [], configuration: PlayerConfiguration = .init()) {
        storedItems = Deque(items)

        nowPlayingSession = MPNowPlayingSession(players: [queuePlayer])

        self.configuration = configuration

        configurePlayer()

        configureControlCenterPublishers()
        configureQueuePlayerUpdatePublishers()
        configurePublishedPropertyPublishers()
    }

    /// Create a player with a single item in its queue.
    /// - Parameters:
    ///   - item: The item to queue.
    ///   - configuration: The configuration to apply to the player.
    public convenience init(item: PlayerItem, configuration: PlayerConfiguration = .init()) {
        self.init(items: [item], configuration: configuration)
    }

    public nonisolated static func == (lhs: Player, rhs: Player) -> Bool {
        lhs === rhs
    }

    /// Enable AirPlay and Control Center integration for the receiver, making the player the current active one. At most
    /// one player can be active at any time.
    public func becomeActive() {
        Self.currentPlayer?.isActive = false
        isActive = true
        Self.currentPlayer = self
    }

    /// Disable AirPlay and Control Center integration for the receiver. Does nothing if the receiver is currently
    /// inactive. Calling `resignActive()` is superfluous if `becomeActive` is called on a different player instance
    /// or if the player gets destroyed.
    public func resignActive() {
        guard isActive, Self.currentPlayer == self else { return }
        isActive = false
        Self.currentPlayer = nil
    }

    private func configurePlayer() {
        queuePlayer.allowsExternalPlayback = false
        queuePlayer.usesExternalPlaybackWhileExternalScreenIsActive = configuration.usesExternalPlaybackWhileMirroring
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = configuration.preventsDisplaySleepDuringVideoPlayback
        queuePlayer.audiovisualBackgroundPlaybackPolicy = configuration.audiovisualBackgroundPlaybackPolicy
    }

    private func configureControlCenterPublishers() {
        guard !ProcessInfo.processInfo.isiOSAppOnMac else { return }
        configureControlCenterMetadataUpdatePublisher()
        configureControlCenterRemoteCommandUpdatePublisher()
    }

    private func configureQueuePlayerUpdatePublishers() {
        configureQueueUpdatePublisher()
        configureRateUpdatePublisher()
    }

    private func configurePublishedPropertyPublishers() {
        configurePlaybackStatePublisher()
        configureChunkDurationPublisher()
        configureSeekingPublisher()
        configureBufferingPublisher()
        configureCurrentItemPublisher()
        configureCurrentIndexPublisher()
        configureCurrentTrackerPublisher()
        configureExternalPlaybackPublisher()
        configurePresentationSizePublisher()
        configureMutedPublisher()
        configurePlaybackSpeedPublisher()
    }

    deinit {
        queuePlayer.cancelPendingReplacements()
        uninstallRemoteCommands()
    }
}

private extension Player {
    func configureQueueUpdatePublisher() {
        assetsPublisher()
            .withPrevious()
            .map { [queuePlayer] sources in
                AVPlayerItem.playerItems(
                    for: sources.current,
                    replacing: sources.previous ?? [],
                    currentItem: queuePlayer.currentItem
                )
            }
            .receiveOnMainThread()
            .sink { [queuePlayer] items in
                queuePlayer.replaceItems(with: items)
            }
            .store(in: &cancellables)
    }

    func configureRateUpdatePublisher() {
        $_playbackSpeed
            .sink { [queuePlayer] speed in
                guard queuePlayer.rate != 0 else { return }
                queuePlayer.defaultRate = speed.effectiveValue
                queuePlayer.rate = speed.effectiveValue
            }
            .store(in: &cancellables)
    }
}

private extension Player {
    func configurePlaybackStatePublisher() {
        queuePlayer.playbackStatePublisher()
            .receiveOnMainThread()
            .lane("player_state")
            .assign(to: &$playbackState)
    }

    func configureChunkDurationPublisher() {
        queuePlayer.chunkDurationPublisher()
            .receiveOnMainThread()
            .lane("player_chunk_duration")
            .assign(to: &$chunkDuration)
    }

    func configureSeekingPublisher() {
        queuePlayer.seekingPublisher()
            .receiveOnMainThread()
            .lane("player_seeking")
            .assign(to: &$isSeeking)
    }

    func configureBufferingPublisher() {
        queuePlayer.bufferingPublisher()
            .receiveOnMainThread()
            .lane("player_buffering")
            .assign(to: &$isBuffering)
    }

    func configureCurrentItemPublisher() {
        queuePlayer.smoothCurrentItemPublisher()
            .receiveOnMainThread()
            .assign(to: &$currentItem)
    }

    func configureCurrentIndexPublisher() {
        currentPublisher()
            .map(\.?.index)
            .receiveOnMainThread()
            .lane("player_current_index")
            .assign(to: &$currentIndex)
    }

    func configureCurrentTrackerPublisher() {
        currentPublisher()
            .map { [weak self] current in
                guard let self, let current else { return nil }
                return CurrentTracker(item: current.item, player: self)
            }
            .receiveOnMainThread()
            .assign(to: &$currentTracker)
    }

    func configureExternalPlaybackPublisher() {
        queuePlayer.publisher(for: \.isExternalPlaybackActive)
            .receiveOnMainThread()
            .assign(to: &$isExternalPlaybackActive)
    }

    func configurePresentationSizePublisher() {
        queuePlayer.presentationSizePublisher()
            .receiveOnMainThread()
            .assign(to: &$presentationSize)
    }

    func configureMutedPublisher() {
        queuePlayer.publisher(for: \.isMuted)
            .receiveOnMainThread()
            .assign(to: &$isMuted)
    }

    func configurePlaybackSpeedPublisher() {
        playbackSpeedUpdatePublisher()
            .scan(.indefinite) { speed, update in
                speed.updated(with: update)
            }
            .removeDuplicates()
            .receiveOnMainThread()
            .assign(to: &$_playbackSpeed)
    }
}

private extension Player {
    func configureControlCenterMetadataUpdatePublisher() {
        Publishers.CombineLatest3(
            nowPlayingInfoMetadataPublisher(),
            queuePlayer.nowPlayingInfoPlaybackPublisher(),
            $isActive
        )
        .receiveOnMainThread()
        .lane("control_center_update")
        .sink { [weak self] nowPlayingInfoMetadata, nowPlayingInfoPlayback, isActive in
            guard let self else { return }
            let nowPlayingInfo = isActive ? nowPlayingInfoMetadata.merging(nowPlayingInfoPlayback) { _, new in new } : [:]
            self.updateControlCenter(nowPlayingInfo: nowPlayingInfo)
        }
        .store(in: &cancellables)
    }

    func configureControlCenterRemoteCommandUpdatePublisher() {
        itemUpdatePublisher()
            .map { update in
                Publishers.CombineLatest3(
                    Just(update.items),
                    Just(update.currentIndex()),
                    update.streamTypePublisher()
                )
            }
            .switchToLatest()
            .sink { [weak self] items, index, streamType in
                guard let self else { return }
                let areSkipsEnabled = items.count <= 1 && streamType != .live
                nowPlayingSession.remoteCommandCenter.skipBackwardCommand.isEnabled = areSkipsEnabled
                nowPlayingSession.remoteCommandCenter.skipForwardCommand.isEnabled = areSkipsEnabled
                nowPlayingSession.remoteCommandCenter.previousTrackCommand.isEnabled = canReturn(before: index, in: items, streamType: streamType)
                nowPlayingSession.remoteCommandCenter.nextTrackCommand.isEnabled = canAdvance(after: index, in: items)
            }
            .store(in: &cancellables)
    }
}

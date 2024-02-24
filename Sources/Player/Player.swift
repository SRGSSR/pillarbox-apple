//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CombineExt
import DequeModule
import MediaPlayer
import PillarboxCore
import TimelaneCombine

/// An observable audio / video player maintaining its items as a double-ended queue.
public final class Player: ObservableObject, Equatable {
    private static weak var currentPlayer: Player?

    /// The player version.
    public static var version: String {
        PackageInfo.version
    }

    /// The last error received by the player.
    @Published public private(set) var error: Error?

    /// The index of the current item in the queue.
    @Published public private(set) var currentIndex: Int?

    /// A Boolean setting whether trackers must be enabled or not.
    @Published public var isTrackingEnabled = true

    @Published var storedItems: Deque<PlayerItem>
    @Published var _playbackSpeed: PlaybackSpeed = .indefinite

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

    var properties: PlayerProperties = .empty {
        willSet {
            guard properties.coreProperties != newValue.coreProperties else {
                return
            }
            objectWillChange.send()
        }
    }

    /// The player configuration.
    public let configuration: PlayerConfiguration

    /// A shared publisher providing player property updates as a consolidated stream.
    ///
    /// Rarely changing player properties, like `mediaType` or `streamType`, can be directly observed and read from
    /// a `Player` instance. Properties which change more often, like `isSeeking` or `buffer`, require an explicit
    /// subscription to be read. You have to register to the `propertiesPublisher` update stream, possibly restricting
    /// observation to a key path using `Publisher.slice(at:)`. Current property values are automatically published
    /// upon subscription.
    ///
    /// When implementing a custom SwiftUI user interface, you should use `View.onReceive(player:assign:to:)` to read
    /// fast-paced property changes into corresponding local bindings.
    public lazy var propertiesPublisher: AnyPublisher<PlayerProperties, Never> = {
        queuePlayer.propertiesPublisher()
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()

    lazy var queuePublisher: AnyPublisher<Queue, Never> = {
        Publishers.Merge(
            queueElementsPublisher()
                .map { QueueUpdate.elements($0) },
            queuePlayer.itemTransitionPublisher()
                .map { QueueUpdate.itemTransition($0) }
        )
        .scan(Queue.initial) { queue, update in
            queue.updated(with: update)
        }
        .share(replay: 1)
        .eraseToAnyPublisher()
    }()

    /// A Boolean setting whether the audio output of the player must be muted.
    public var isMuted: Bool {
        get {
            properties.isMuted
        }
        set {
            queuePlayer.isMuted = newValue
        }
    }

    /// The current time.
    public var time: CMTime {
        queuePlayer.currentTime().clamped(to: seekableTimeRange)
    }

    /// The low-level system player.
    ///
    /// Exposed for specific read-only needs like interfacing with `AVPlayer`-based 3rd party APIs. Mutating the state
    /// of this player directly is not supported and leads to undefined behavior.
    public var systemPlayer: AVPlayer {
        queuePlayer
    }

    /// A policy that determines how playback of audiovisual media continues when the app transitions
    /// to the background.
    public var audiovisualBackgroundPlaybackPolicy: AVPlayerAudiovisualBackgroundPlaybackPolicy {
        get {
            queuePlayer.audiovisualBackgroundPlaybackPolicy
        }
        set {
            queuePlayer.audiovisualBackgroundPlaybackPolicy = newValue
        }
    }

    /// A Boolean value whether the player should play content when possible.
    public var shouldPlay: Bool {
        get {
            queuePlayer.rate != 0
        }
        set {
            if newValue {
                queuePlayer.rate = queuePlayer.defaultRate
            }
            else {
                queuePlayer.rate = 0
            }
        }
    }

    let queuePlayer = QueuePlayer()
    let nowPlayingSession: MPNowPlayingSession

    var cancellables = Set<AnyCancellable>()
    var commandRegistrations: [any RemoteCommandRegistrable] = []

    // swiftlint:disable:next private_subject
    var desiredPlaybackSpeedPublisher = PassthroughSubject<Float, Never>()

    // swiftlint:disable:next private_subject
    var textStyleRulesPublisher = CurrentValueSubject<[AVTextStyleRule], Never>([])

    /// Creates a player with a given item queue.
    ///
    /// - Parameters:
    ///   - items: The items to be queued initially.
    ///   - configuration: The configuration to apply to the player.
    public init(items: [PlayerItem] = [], configuration: PlayerConfiguration = .init()) {
        storedItems = Deque(items)
        nowPlayingSession = MPNowPlayingSession(players: [queuePlayer])
        self.configuration = configuration

        configurePlayer()

        configureControlCenterPublishers() // TODO: Should we move this line?
        configurePublishedPropertyPublishers()
        configureQueuePlayerUpdatePublishers()
    }

    /// Creates a player with a single item in its queue.
    ///
    /// - Parameters:
    ///   - item: The item to queue.
    ///   - configuration: The configuration to apply to the player.
    public convenience init(item: PlayerItem, configuration: PlayerConfiguration = .init()) {
        self.init(items: [item], configuration: configuration)
    }

    public static func == (lhs: Player, rhs: Player) -> Bool {
        lhs === rhs
    }

    /// Enables AirPlay and Control Center integration for the receiver, making the player the current active one.
    ///
    /// At most one player can be active at any time.
    public func becomeActive() {
        guard Self.currentPlayer != self else { return }
        Self.currentPlayer?.isActive = false
        isActive = true
        Self.currentPlayer = self
    }

    /// Disables AirPlay and Control Center integration for the receiver.
    ///
    /// Does nothing if the receiver is currently inactive. Calling `resignActive()` is superfluous when `becomeActive()`
    /// is called on a different player instance or when the player gets destroyed.
    public func resignActive() {
        guard Self.currentPlayer == self else { return }
        isActive = false
        Self.currentPlayer = nil
    }

    private func configurePlayer() {
        queuePlayer.allowsExternalPlayback = false
        queuePlayer.usesExternalPlaybackWhileExternalScreenIsActive = configuration.usesExternalPlaybackWhileMirroring
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = configuration.preventsDisplaySleepDuringVideoPlayback
    }

    private func configureControlCenterPublishers() {
        guard !ProcessInfo.processInfo.isiOSAppOnMac else { return }
        configureControlCenterMetadataUpdatePublisher()
        configureControlCenterRemoteCommandUpdatePublisher()
    }

    private func configureQueuePlayerUpdatePublishers() {
        configureQueuePlayerItemsPublisher()
        configureRateUpdatePublisher()
        configureTextStyleRulesUpdatePublisher()
    }

    private func configurePublishedPropertyPublishers() {
        configurePropertiesPublisher()
        configureErrorPublisher()
        configureCurrentIndexPublisher()
        configureCurrentTrackerPublisher()
        configurePlaybackSpeedPublisher()
    }

    deinit {
        uninstallRemoteCommands()

        // Avoid sound continuing in background when the underlying `AVQueuePlayer` is kept for a little while longer, 
        // see https://github.com/SRGSSR/pillarbox-apple/issues/520
        queuePlayer.volume = 0
    }
}

private extension Player {
    func configureQueuePlayerItemsPublisher() {
        queuePlayerItemsPublisher()
            .receiveOnMainThread()
            .sink { [queuePlayer] items in
                queuePlayer.replaceItems(with: items)
            }
            .store(in: &cancellables)
    }

    func configureRateUpdatePublisher() {
        $_playbackSpeed
            .sink { [queuePlayer] speed in
                queuePlayer.defaultRate = speed.effectiveValue
                guard queuePlayer.rate != 0 else { return }
                queuePlayer.rate = speed.effectiveValue
            }
            .store(in: &cancellables)
    }

    func configureTextStyleRulesUpdatePublisher() {
        Publishers.CombineLatest(
            textStyleRulesPublisher,
            queuePlayer.currentItemPublisher()
        )
        .sink { textStyleRules, item in
            item?.textStyleRules = textStyleRules
        }
        .store(in: &cancellables)
    }
}

private extension Player {
    func configurePropertiesPublisher() {
        propertiesPublisher
            .receiveOnMainThread()
            .weakAssign(to: \.properties, on: self)
            .store(in: &cancellables)
    }

    func configureErrorPublisher() {
        queuePublisher
            .map(\.error)
            .removeDuplicates { $0 as? NSError == $1 as? NSError }
            .receiveOnMainThread()
            .assign(to: &$error)
    }

    func configureCurrentIndexPublisher() {
        queuePublisher
            .slice(at: \.currentIndex)
            .receiveOnMainThread()
            .lane("player_current_index")
            .assign(to: &$currentIndex)
    }

    func configureCurrentTrackerPublisher() {
        queuePublisher
            .slice(at: \.currentItem)
            .map { [weak self] item in
                guard let self, let item else { return nil }
                return CurrentTracker(item: item, player: self)
            }
            .receiveOnMainThread()
            .assign(to: &$currentTracker)
    }

    func configurePlaybackSpeedPublisher() {
        playbackSpeedPublisher()
            .receiveOnMainThread()
            .assign(to: &$_playbackSpeed)
    }
}

private extension Player {
    func configureControlCenterMetadataUpdatePublisher() {
        Publishers.CombineLatest3(
            nowPlayingInfoMetadataPublisher(),
            nowPlayingInfoPlaybackPublisher(),
            $isActive
        )
        .receiveOnMainThread()
        .sink { [weak self] nowPlayingInfoMetadata, nowPlayingInfoPlayback, isActive in
            guard let self else { return }
            let nowPlayingInfo = isActive ? nowPlayingInfoMetadata.merging(nowPlayingInfoPlayback) { _, new in new } : [:]
            updateControlCenter(nowPlayingInfo: nowPlayingInfo)
        }
        .store(in: &cancellables)
    }

    func configureControlCenterRemoteCommandUpdatePublisher() {
        Publishers.CombineLatest(
            queuePublisher,
            propertiesPublisher
        )
        .sink { [weak self] queue, properties in
            guard let self else { return }
            let areSkipsEnabled = queue.elements.count <= 1 && properties.streamType != .live
            let hasError = queue.error != nil
            nowPlayingSession.remoteCommandCenter.skipBackwardCommand.isEnabled = areSkipsEnabled && !hasError && canSkipForward()
            nowPlayingSession.remoteCommandCenter.skipForwardCommand.isEnabled = areSkipsEnabled && !hasError && canSkipBackward()
            nowPlayingSession.remoteCommandCenter.changePlaybackPositionCommand.isEnabled = !hasError

            let index = queue.currentIndex
            let items = Deque(queue.elements.map(\.item))
            nowPlayingSession.remoteCommandCenter.previousTrackCommand.isEnabled = canReturn(before: index, in: items, streamType: properties.streamType)
            nowPlayingSession.remoteCommandCenter.nextTrackCommand.isEnabled = canAdvance(after: index, in: items)
        }
        .store(in: &cancellables)
    }
}

private extension Player {
    func queuePlayerItemsPublisher() -> AnyPublisher<[AVPlayerItem], Never> {
        queuePublisher
            .withPrevious(Queue.initial)
            .compactMap { [configuration] previous, current in
                switch current.itemTransition {
                case let .go(to: item):
                    return AVPlayerItem.playerItems(
                        for: current.elements.map(\.asset),
                        replacing: previous.elements.map(\.asset),
                        currentItem: item,
                        length: configuration.preloadedItems
                    )
                case let .stop(on: item, with: _):
                    if previous.elements.count == current.elements.count {
                        return [item]
                    }
                    else {
                        return AVPlayerItem.playerItems(
                            for: current.elements.map(\.asset),
                            replacing: previous.elements.map(\.asset),
                            currentItem: item,
                            length: configuration.preloadedItems
                        )
                    }
                case .finish:
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    private func queueElementsPublisher() -> AnyPublisher<[QueueElement], Never> {
        $storedItems
            .map { items in
                Publishers.AccumulateLatestMany(items.map { item in
                    item.$asset
                        .map { QueueElement(item: item, asset: $0) }
                })
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

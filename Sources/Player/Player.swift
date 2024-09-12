//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import DequeModule
import MediaPlayer
import PillarboxCore

/// An observable audio / video player maintaining its items as a double-ended queue.
public final class Player: ObservableObject, Equatable {
    private static weak var currentPlayer: Player?

    /// The player version.
    public static let version = PackageInfo.version

    /// The current item.
    public var currentItem: PlayerItem? {
        get {
            tracker?.item
        }
        set {
            replaceCurrentItemWithItem(newValue)
        }
    }

    /// The last error received by the player.
    @Published public private(set) var error: Error?

    /// The metadata related to the item being played.
    @Published public private(set) var metadata: PlayerMetadata = .empty

    /// The mode with which the player repeats playback of items in its queue.
    @Published public var repeatMode: RepeatMode = .off {
        didSet {
            guard !canReplay() else { return }
            reloadItems()
        }
    }

    @Published var storedItems: Deque<PlayerItem>
    @Published var _playbackSpeed: PlaybackSpeed = .indefinite

    @Published var isActive = false {
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

    @Published var tracker: Tracker? {
        didSet {
            tracker?.isEnabled = isTrackingEnabled
        }
    }

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
        currentPlayerItemPublisher()
            .map { [queuePlayer] item in
                guard let item else { return Just(PlayerProperties.empty).eraseToAnyPublisher() }
                return item.propertiesPublisher(with: queuePlayer)
            }
            .switchToLatest()
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()

    lazy var queuePublisher: AnyPublisher<Queue, Never> = {
        Publishers.Merge(
            elementsQueueUpdatePublisher(),
            itemStateQueueUpdatePublisher()
        )
        .scan(.empty) { queue, update -> Queue in
            queue.updated(with: update)
        }
        .share(replay: 1)
        .eraseToAnyPublisher()
    }()

    lazy var metadataPublisher: AnyPublisher<PlayerMetadata, Never> = {
        currentItemPublisher()
            .map { item -> AnyPublisher<PlayerMetadata, Never> in
                guard let item else { return Just(.empty).eraseToAnyPublisher() }
                return item.metadataPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
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

    /// A Boolean setting whether trackers must be enabled or not.
    ///
    /// This property only affects trackers having optional ``TrackingBehavior``, set when creating a corresponding
    /// adapter using ``PlayerItemTracker/adapter(configuration:behavior:mapper:)`` or similar methods.
    ///
    public var isTrackingEnabled = true {
        didSet {
            tracker?.isEnabled = isTrackingEnabled
        }
    }

    /// The low-level system player.
    ///
    /// Exposed for specific read-only needs like interfacing with `AVPlayer`-based 3rd party APIs. Mutating the state
    /// of this player directly is not supported and leads to undefined behavior.
    public var systemPlayer: AVPlayer {
        queuePlayer
    }

    /// The action that the player should perform when playback of an item ends.
    ///
    /// The default value is `.advance`.
    public var actionAtItemEnd: AVPlayer.ActionAtItemEnd {
        get {
            queuePlayer.actionAtItemEnd
        }
        set {
            queuePlayer.actionAtItemEnd = newValue
        }
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
    public init(items: [PlayerItem] = [], configuration: PlayerConfiguration = .default) {
        storedItems = Deque(items)

        // TODO: Check the behavior in the future tvOS versions, see https://github.com/SRGSSR/pillarbox-apple/issues/826
#if os(tvOS)
        nowPlayingSession = MPNowPlayingSession(players: [AVPlayer()])
#else
        nowPlayingSession = MPNowPlayingSession(players: [queuePlayer])
#endif
        self.configuration = configuration

        configurePlayer()
        configureAudioSessionPublisher()
        configurePublishedPropertyPublishers()
        configureQueuePlayerUpdatePublishers()
        configureTrackerPublisher()
        configureControlCenterPublishers()
        configureMetadataPublisher()
        configureBlockedTimeRangesPublishers()
    }

    /// Creates a player with a single item in its queue.
    ///
    /// - Parameters:
    ///   - item: The item to queue.
    ///   - configuration: The configuration to apply to the player.
    public convenience init(item: PlayerItem, configuration: PlayerConfiguration = .default) {
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

    /// The list of current sessions managed by trackers of a specific type.
    ///
    /// Only trackers with an associated ``PlayerItemTracker/sessionIdentifier`` are returned.
    public func currentSessionIdentifiers<T>(trackedBy type: T.Type) -> [String] where T: PlayerItemTracker {
        guard let currentItem else { return [] }
        return currentItem.sessionIdentifiers(trackedBy: type)
    }

    private func configurePlayer() {
        queuePlayer.allowsExternalPlayback = false
        queuePlayer.usesExternalPlaybackWhileExternalScreenIsActive = configuration.usesExternalPlaybackWhileMirroring
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = configuration.preventsDisplaySleepDuringVideoPlayback
    }

    deinit {
        uninstallRemoteCommands()

        // Avoid sound continuing in background when the underlying `AVQueuePlayer` is kept for a little while longer, 
        // see https://github.com/SRGSSR/pillarbox-apple/issues/520
        queuePlayer.volume = 0
    }
}

public extension Player {
    /// The current time.
    ///
    /// Returns `.invalid` when the time is unknown.
    func time() -> CMTime {
        properties.time()
    }

    /// The current date.
    ///
    /// The date is `nil` when no date information is available from the stream.
    func date() -> Date? {
        properties.date()
    }

    /// The current player metrics, if available.
    ///
    /// Each call to this function might return different results reflecting the most recent metrics available. The
    /// included ``Metrics/increment`` collates data from the entire playback session and is therefore always equal
    /// to ``Metrics/total``.
    ///
    /// > Important: Metrics are reset when toggling external playback.
    func metrics() -> Metrics? {
        properties.metrics()
    }
}

private extension Player {
    func configurePublishedPropertyPublishers() {
        configurePropertiesPublisher()
        configureErrorPublisher()
        configurePlaybackSpeedPublisher()
    }

    func configureQueuePlayerUpdatePublishers() {
        configureQueuePlayerItemsPublisher()
        configureRateUpdatePublisher()
        configureTextStyleRulesUpdatePublisher()
    }

    func configureTrackerPublisher() {
        queuePublisher
            .slice(at: \.items)
            .sink { [weak self] items in
                self?.updateTracker(with: items)
            }
            .store(in: &cancellables)
    }

    func configureControlCenterPublishers() {
        guard !ProcessInfo.processInfo.isiOSAppOnMac else { return }
        configureControlCenterMetadataUpdatePublisher()
        configureControlCenterRemoteCommandUpdatePublisher()
    }

    func configureMetadataPublisher() {
        metadataPublisher
            .receiveOnMainThread()
            .assign(to: &$metadata)
    }

    func configureBlockedTimeRangesPublishers() {
        nextUnblockedTimePublisher()
            .sink { [weak self] time in
                self?.seek(at(time))
            }
            .store(in: &cancellables)

        metadataPublisher.slice(at: \.blockedTimeRanges)
            .assign(to: \.blockedTimeRanges, on: queuePlayer)
            .store(in: &cancellables)
    }

    func configureAudioSessionPublisher() {
        AVAudioSession.enableSetCategoryNotifications()
        NotificationCenter.default.publisher(for: .didSetAudioSessionCategory)
            .map { _ in false }
            .receiveOnMainThread()
            .assign(to: &$isActive)
    }

    func updateTracker(with items: QueueItems?) {
        if let items {
            if items.item == tracker?.item {
                tracker?.playerItem = items.playerItem
            }
            else {
                tracker = Tracker(items: items, player: queuePlayer, isEnabled: isTrackingEnabled)
            }
        }
        else {
            tracker = nil
        }
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

    func configurePlaybackSpeedPublisher() {
        playbackSpeedPublisher()
            .receiveOnMainThread()
            .assign(to: &$_playbackSpeed)
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
            currentPlayerItemPublisher()
        )
        .sink { textStyleRules, item in
            item?.textStyleRules = textStyleRules
        }
        .store(in: &cancellables)
    }
}

private extension Player {
    func configureControlCenterMetadataUpdatePublisher() {
        nowPlayingPublisher()
            .receiveOnMainThread()
            .sink { [weak self] nowPlaying in
                self?.updateControlCenter(nowPlaying: nowPlaying)
            }
            .store(in: &cancellables)
    }

    func configureControlCenterRemoteCommandUpdatePublisher() {
        Publishers.CombineLatest3(
            queuePublisher,
            propertiesPublisher,
            $isActive
        )
        .receiveOnMainThread()
        .sink { [weak self] queue, properties, _ in
            guard let self else { return }
            let areSkipsEnabled = queue.elements.count <= 1 && properties.streamType != .live
            let hasError = queue.error != nil
            nowPlayingSession.remoteCommandCenter.skipBackwardCommand.isEnabled = areSkipsEnabled && !hasError && canSkipForward()
            nowPlayingSession.remoteCommandCenter.skipForwardCommand.isEnabled = areSkipsEnabled && !hasError && canSkipBackward()
            nowPlayingSession.remoteCommandCenter.changePlaybackPositionCommand.isEnabled = !hasError

            let items = Deque(queue.elements.map(\.item))
            nowPlayingSession.remoteCommandCenter.previousTrackCommand.isEnabled = canReturn(before: queue.item, in: items, streamType: properties.streamType)
            nowPlayingSession.remoteCommandCenter.nextTrackCommand.isEnabled = canAdvance(after: queue.item, in: items)
        }
        .store(in: &cancellables)
    }
}

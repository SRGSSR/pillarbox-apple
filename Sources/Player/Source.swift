//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol Sourceable {
    associatedtype M
    var id: UUID { get }
    var assetId: UUID { get }
    var asset: Asset<M> { get }
    func enable(for player: Player)
    func updateMetadata()
    func disable()
    func nowPlayingInfo() -> NowPlayingInfo

    func matches(_ playerItem: AVPlayerItem?) -> Bool
}

/// A source to generate an `AVPlayerItem` from.
struct Source<T: PlayerItemTracker, M>: Sourceable {
    let id: UUID
    let asset: Asset<M>
    let trackers: [TrackerAdapter<T, M>]

    var assetId: UUID {
        asset.id
    }

    func enable(for player: Player) {
        asset.enable(trackers: trackers, for: player)
    }

    func updateMetadata() {
        asset.update(trackers: trackers)
    }

    func disable() {
        asset.disable(trackers: trackers)
    }

    func nowPlayingInfo() -> NowPlayingInfo {
        asset.nowPlayingInfo()
    }
}

extension AVPlayerItem {
    /// Return the list of `AVPlayerItems` to load into an `AVQueuePlayer` when a list of sources replaces a previous
    /// one.
    /// - Parameters:
    ///   - currentSources: The current list of sources.
    ///   - previousSources: The previous list of sources.
    ///   - currentItem: The item currently being played by the player.
    /// - Returns: The list of player items to load into the player.
    static func playerItems(
        for currentSources: [any Sourceable],
        replacing previousSources: [any Sourceable],
        currentItem: AVPlayerItem?
    ) -> [AVPlayerItem] {
        guard let currentItem else { return playerItems(from: currentSources) }
        if let currentIndex = matchingIndex(for: currentItem, in: currentSources) {
            if findSource(for: currentItem, in: previousSources, equalTo: currentSources[currentIndex]) {
                return [currentItem] + playerItems(from: Array(currentSources.suffix(from: currentIndex + 1)))
            }
            else {
                return playerItems(from: Array(currentSources.suffix(from: currentIndex)))
            }
        }
        else if let commonIndex = firstCommonIndex(in: currentSources, matching: previousSources, after: currentItem) {
            return playerItems(from: Array(currentSources.suffix(from: commonIndex)))
        }
        else {
            return playerItems(from: currentSources)
        }
    }

    static func playerItems(from sources: [any Sourceable]) -> [AVPlayerItem] {
        sources.map { $0.playerItem() }
    }

    private static func matchingIndex(for item: AVPlayerItem, in sources: [any Sourceable]) -> Int? {
        sources.firstIndex { $0.matches(item) }
    }

    private static func firstMatchingIndex(for sources: [any Sourceable], in other: [any Sourceable]) -> Int? {
        guard let match = sources.first(where: { source in
            other.contains(where: { $0.id == source.id })
        }) else {
            return nil
        }
        return matchingIndex(for: match, in: other)
    }

    private static func matchingSource(for item: AVPlayerItem, in sources: [any Sourceable]) -> (any Sourceable)? {
        sources.first { $0.matches(item) }
    }

    private static func matchingIndex(for source: any Sourceable, in sources: [any Sourceable]) -> Int? {
        sources.firstIndex { $0.id == source.id }
    }

    private static func findSource(for item: AVPlayerItem, in sources: [any Sourceable], equalTo other: any Sourceable) -> Bool {
        guard let match = matchingSource(for: item, in: sources) else { return false }
        return match.assetId == other.assetId
    }

    private static func firstCommonIndex(in sources: [any Sourceable], matching other: [any Sourceable], after item: AVPlayerItem) -> Int? {
        guard let matchIndex = matchingIndex(for: item, in: other) else { return nil }
        return firstMatchingIndex(for: Array(other.suffix(from: matchIndex + 1)), in: sources)
    }
}

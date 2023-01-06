//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A source to generate an `AVPlayerItem` from.
struct Source: Identifiable, Equatable {
    let id: UUID
    let asset: Asset

    static func == (lhs: Source, rhs: Source) -> Bool {
        lhs.id == rhs.id && lhs.asset == rhs.asset
    }

    func playerItem() -> AVPlayerItem {
        asset.playerItem().withId(id)
    }

    func matches(_ item: AVPlayerItem?) -> Bool {
        id == item?.id
    }
}

extension Source {
    /// Return the list of `AVPlayerItems` to load into an `AVQueuePlayer` when a list of sources replaces a previous
    /// one.
    /// - Parameters:
    ///   - currentSources: The current list of sources.
    ///   - previousSources: The previous list of sources.
    ///   - currentItem: The item currently being played by the player.
    /// - Returns: The list of player items to load into the player.
    static func playerItems(
        for currentSources: [Source],
        replacing previousSources: [Source],
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

    static func playerItems(from sources: [Source]) -> [AVPlayerItem] {
        sources.map { $0.playerItem() }
    }

    private static func matchingIndex(for item: AVPlayerItem, in sources: [Source]) -> Int? {
        sources.firstIndex { $0.matches(item) }
    }

    private static func firstMatchingIndex(for sources: [Source], in other: [Source]) -> Int? {
        guard let match = sources.first(where: { source in
            other.contains(where: { $0.id == source.id })
        }) else {
            return nil
        }
        return matchingIndex(for: match, in: other)
    }

    private static func matchingSource(for item: AVPlayerItem, in sources: [Source]) -> Source? {
        sources.first { $0.matches(item) }
    }

    private static func matchingIndex(for source: Source, in sources: [Source]) -> Int? {
        sources.firstIndex { $0.id == source.id }
    }

    private static func findSource(for item: AVPlayerItem, in sources: [Source], equalTo other: Source) -> Bool {
        guard let match = matchingSource(for: item, in: sources) else { return false }
        return match == other
    }

    private static func firstCommonIndex(in sources: [Source], matching other: [Source], after item: AVPlayerItem) -> Int? {
        guard let matchIndex = matchingIndex(for: item, in: other) else { return nil }
        return firstMatchingIndex(for: Array(other.suffix(from: matchIndex + 1)), in: sources)
    }
}

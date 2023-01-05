//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A source to generate `AVPlayerItem` from.
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
    static func playerItems(for currentSources: [Source], replacing previousSources: [Source], currentItem: AVPlayerItem?) -> [AVPlayerItem] {
        guard let currentItem else { return items(from: currentSources) }
        if let currentItemIndex = matchingIndex(for: currentItem, in: currentSources) {
            if containsSource(for: currentItem, in: previousSources, equalTo: currentSources[currentItemIndex]) {
                return [currentItem] + items(from: Array(currentSources.suffix(from: currentItemIndex + 1)))
            }
            else {
                return items(from: Array(currentSources.suffix(from: currentItemIndex)))
            }
        }
        else if let commonIndex = commonIndex(after: currentItem, of: previousSources, in: currentSources) {
            return items(from: Array(currentSources.suffix(from: commonIndex)))
        }
        else {
            return items(from: currentSources)
        }
    }

    private static func matchingIndex(for item: AVPlayerItem, in sources: [Source]) -> Int? {
        sources.firstIndex(where: { $0.matches(item) })
    }

    private static func matchingSource(for item: AVPlayerItem, in sources: [Source]) -> Source? {
        sources.first(where: { $0.matches(item) })
    }

    private static func matchingIndex(for candidates: [Source], in sources: [Source]) -> Int? {
        guard let match = candidates.first(where: { candidate in
            sources.contains(where: { $0.id == candidate.id })
        }) else {
            return nil
        }
        return matchingIndex(for: match, in: sources)
    }

    private static func matchingIndex(for source: Source, in sources: [Source]) -> Int? {
        sources.firstIndex(where: { $0.id == source.id })
    }

    private static func containsSource(for item: AVPlayerItem, in sources: [Source], equalTo other: Source) -> Bool {
        guard let match = matchingSource(for: item, in: sources) else { return false }
        return match == other
    }

    private static func items(from sources: [Source]) -> [AVPlayerItem] {
        sources.map { $0.playerItem() }
    }

    private static func commonIndex(after item: AVPlayerItem, of initial: [Source], in final: [Source]) -> Int? {
        guard let matchIndex = matchingIndex(for: item, in: initial) else { return nil }
        let nextSources = Array(initial.suffix(from: matchIndex + 1))
        return matchingIndex(for: nextSources, in: final)
    }
}

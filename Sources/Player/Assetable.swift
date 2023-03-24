//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol Assetable {
    var id: UUID { get }
    var type: AssetType { get }

    func enable(for player: Player)
    func updateMetadata()
    func disable()
    func nowPlayingInfo() -> NowPlaying.Info
    func matches(_ playerItem: AVPlayerItem?) -> Bool
    func playerItem() -> AVPlayerItem
}

extension AVPlayerItem {
    /// Return the list of `AVPlayerItems` to load into an `AVQueuePlayer` when a list of assets replaces a previous
    /// one.
    /// - Parameters:
    ///   - currentAssets: The current list of assets.
    ///   - previousAssets: The previous list of assets.
    ///   - currentItem: The item currently being played by the player.
    /// - Returns: The list of player items to load into the player.
    static func playerItems(
        for currentAssets: [any Assetable],
        replacing previousAssets: [any Assetable],
        currentItem: AVPlayerItem?
    ) -> [AVPlayerItem] {
        guard let currentItem else { return playerItems(from: currentAssets) }
        if let currentIndex = matchingIndex(for: currentItem, in: currentAssets) {
            if findAsset(for: currentItem, in: previousAssets, equalTo: currentAssets[currentIndex]) {
                return [currentItem] + playerItems(from: Array(currentAssets.suffix(from: currentIndex + 1)))
            }
            else {
                return playerItems(from: Array(currentAssets.suffix(from: currentIndex)))
            }
        }
        else if let commonIndex = firstCommonIndex(in: currentAssets, matching: previousAssets, after: currentItem) {
            return playerItems(from: Array(currentAssets.suffix(from: commonIndex)))
        }
        else {
            return playerItems(from: currentAssets)
        }
    }

    static func playerItems(from assets: [any Assetable]) -> [AVPlayerItem] {
        assets.map { $0.playerItem() }
    }

    private static func matchingIndex(for item: AVPlayerItem, in assets: [any Assetable]) -> Int? {
        assets.firstIndex { $0.matches(item) }
    }

    private static func firstMatchingIndex(for assets: [any Assetable], in other: [any Assetable]) -> Int? {
        guard let match = assets.first(where: { asset in
            other.contains(where: { $0.id == asset.id })
        }) else {
            return nil
        }
        return matchingIndex(for: match, in: other)
    }

    private static func matchingAsset(for item: AVPlayerItem, in assets: [any Assetable]) -> (any Assetable)? {
        assets.first { $0.matches(item) }
    }

    private static func matchingIndex(for asset: any Assetable, in assets: [any Assetable]) -> Int? {
        assets.firstIndex { $0.id == asset.id }
    }

    private static func findAsset(for item: AVPlayerItem, in assets: [any Assetable], equalTo other: any Assetable) -> Bool {
        guard let match = matchingAsset(for: item, in: assets) else { return false }
        return match.type == other.type
    }

    private static func firstCommonIndex(in assets: [any Assetable], matching other: [any Assetable], after item: AVPlayerItem) -> Int? {
        guard let matchIndex = matchingIndex(for: item, in: other) else { return nil }
        return firstMatchingIndex(for: Array(other.suffix(from: matchIndex + 1)), in: assets)
    }
}

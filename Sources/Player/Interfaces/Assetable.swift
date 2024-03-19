//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A protocol describing an asset.
protocol Assetable {
    associatedtype Metadata

    var id: UUID { get }
    var resource: Resource { get }
    var metadataAdapter: MetadataAdapter<Metadata>? { get }
    var trackerAdapters: [TrackerAdapter<Metadata>] { get }

    func updateMetadata()

    func configure(item: AVPlayerItem)
    func update(item: AVPlayerItem)
}

extension Assetable {
    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        id == playerItem?.id
    }

    func enable(for player: Player) {
        trackerAdapters.forEach { adapter in
            adapter.enable(for: player)
        }
    }

    func disable() {
        trackerAdapters.forEach { adapter in
            adapter.disable()
        }
    }

    func playerItem(reload: Bool = false) -> AVPlayerItem {
        if reload, resource.isFailing {
            let item = Resource.loading.playerItem().withId(id)
            configure(item: item)
            update(item: item)
            PlayerItem.reload(for: id)
            return item
        }
        else {
            let item = resource.playerItem().withId(id)
            configure(item: item)
            update(item: item)
            PlayerItem.load(for: id)
            return item
        }
    }

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo {
        metadataAdapter?.mediaItemInfo(with: error) ?? .init()
    }
}

extension AVPlayerItem {
    /// Returns the list of `AVPlayerItems` to load into an `AVQueuePlayer` when a list of assets replaces a previous
    /// one.
    /// 
    /// - Parameters:
    ///   - currentAssets: The current list of assets.
    ///   - previousAssets: The previous list of assets.
    ///   - currentItem: The item currently being played by the player.
    /// - Returns: The list of player items to load into the player.
    static func playerItems(
        for currentAssets: [any Assetable],
        replacing previousAssets: [any Assetable],
        currentItem: AVPlayerItem?,
        length: Int
    ) -> [AVPlayerItem] {
        guard let currentItem else { return playerItems(from: Array(currentAssets.prefix(length))) }
        if let currentIndex = matchingIndex(for: currentItem, in: currentAssets) {
            let currentAsset = currentAssets[currentIndex]
            if findAsset(currentAsset, in: previousAssets) {
                currentAsset.update(item: currentItem)
                return [currentItem] + playerItems(from: Array(currentAssets.suffix(from: currentIndex + 1).prefix(length - 1)))
            }
            else {
                return playerItems(from: Array(currentAssets.suffix(from: currentIndex).prefix(length)))
            }
        }
        else if let commonIndex = firstCommonIndex(in: currentAssets, matching: previousAssets, after: currentItem) {
            return playerItems(from: Array(currentAssets.suffix(from: commonIndex).prefix(length)))
        }
        else {
            return playerItems(from: Array(currentAssets.prefix(length)))
        }
    }

    static func playerItems(from assets: [any Assetable], reload: Bool = false) -> [AVPlayerItem] {
        assets.map { $0.playerItem(reload: reload) }
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

    private static func matchingIndex(for asset: any Assetable, in assets: [any Assetable]) -> Int? {
        assets.firstIndex { $0.id == asset.id }
    }

    private static func findAsset(_ asset: any Assetable, in assets: [any Assetable]) -> Bool {
        guard let match = assets.first(where: { $0.id == asset.id }) else { return false }
        return match.resource == asset.resource
    }

    private static func firstCommonIndex(in assets: [any Assetable], matching other: [any Assetable], after item: AVPlayerItem) -> Int? {
        guard let matchIndex = matchingIndex(for: item, in: other) else { return nil }
        return firstMatchingIndex(for: Array(other.suffix(from: matchIndex + 1)), in: assets)
    }
}

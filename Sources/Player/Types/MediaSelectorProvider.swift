//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelectorProvider {
    private let group: AVMediaSelectionGroup
    private let cache: AVAssetCache?

    let options: [AVMediaSelectionOption]

    init(group: AVMediaSelectionGroup, cache: AVAssetCache?) {
        self.group = group
        self.cache = cache
        self.options = Self.options(group: group, cache: cache)
    }

    private static func options(group: AVMediaSelectionGroup, cache: AVAssetCache?) -> [AVMediaSelectionOption] {
        if let cache, cache.isPlayableOffline {
            return cache.mediaSelectionOptions(in: group)
        }
        else {
            return group.options
        }
    }

    func selectedMediaOption(in selection: AVMediaSelection?) -> AVMediaSelectionOption? {
        guard let option = selection?.selectedMediaOption(in: group) else { return nil }
        return options.contains(option) ? option : nil
    }

    func select(_ option: AVMediaSelectionOption?, for item: AVPlayerItem) {
        if let option, !options.contains(option) {
            return
        }
        item.select(option, in: group)
    }

    func selecting(_ option: AVMediaSelectionOption?, in selection: AVMediaSelection) -> AVMediaSelection {
        if let option, !options.contains(option) {
            return selection
        }
        guard let updatedSelection = selection.mutableCopy() as? AVMutableMediaSelection else { return selection }
        updatedSelection.select(option, in: group)
        return updatedSelection
    }

    func selectMediaOptionAutomatically(for item: AVPlayerItem) {
        item.selectMediaOptionAutomatically(in: group)
    }
}

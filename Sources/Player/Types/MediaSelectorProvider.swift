//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelectorProvider {
    private let group: AVMediaSelectionGroup
    private let cache: AVAssetCache?

    var options: [AVMediaSelectionOption] {
        if let cache, cache.isPlayableOffline {
            return cache.mediaSelectionOptions(in: group)
        }
        else {
            return group.options
        }
    }

    init(group: AVMediaSelectionGroup, cache: AVAssetCache?) {
        self.group = group
        self.cache = cache
    }

    func selectedMediaOption(in selection: AVMediaSelection?) -> AVMediaSelectionOption? {
        selection?.selectedMediaOption(in: group)
    }

    func select(_ option: AVMediaSelectionOption?, for item: AVPlayerItem) {
        item.select(option, in: group)
    }

    func selecting(_ option: AVMediaSelectionOption?, in selection: AVMediaSelection) -> AVMediaSelection {
        guard let updatedSelection = selection.mutableCopy() as? AVMutableMediaSelection else { return selection }
        updatedSelection.select(option, in: group)
        return updatedSelection
    }

    func selectMediaOptionAutomatically(for item: AVPlayerItem) {
        item.selectMediaOptionAutomatically(in: group)
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelectionProvider: Equatable {
    static let empty = Self(groups: [:], cache: nil)

    private let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]
    private let cache: AVAssetCache?

    var characteristics: Set<AVMediaCharacteristic> {
        Set(groups.keys)
    }

    init(groups: [AVMediaCharacteristic: AVMediaSelectionGroup], cache: AVAssetCache?) {
        self.groups = groups
        self.cache = cache
    }

    func mediaSelectorProvider(for characteristic: AVMediaCharacteristic) -> MediaSelectorProvider? {
        guard let group = groups[characteristic] else { return nil }
        return .init(group: group, cache: cache)
    }
}

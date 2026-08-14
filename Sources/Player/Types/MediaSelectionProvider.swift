//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelectionProvider: Equatable {
    static let empty = Self(groups: [:], cache: nil)

    private let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]

    var characteristics: Set<AVMediaCharacteristic> {
        Set(groups.keys)
    }

    init(groups: [AVMediaCharacteristic: AVMediaSelectionGroup], cache: AVAssetCache?) {
        self.groups = groups
    }

    func group(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? {
        groups[characteristic]
    }
}

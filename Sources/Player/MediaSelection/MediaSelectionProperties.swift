//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelectionProperties: Equatable {
    static var empty: Self {
        self.init(groups: [:], selection: nil)
    }

    private let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]
    let selection: AVMediaSelection?

    var characteristics: Set<AVMediaCharacteristic> {
        Set(groups.keys)
    }

    init(groups: [AVMediaCharacteristic: AVMediaSelectionGroup], selection: AVMediaSelection?) {
        self.groups = groups
        self.selection = selection
    }

    func group(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? {
        groups[characteristic]
    }

    func selectedOption(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionOption? {
        guard let selection, let group = groups[characteristic] else { return nil }
        return selection.selectedMediaOption(in: group)
    }

    func reset(for characteristic: AVMediaCharacteristic, in item: AVPlayerItem) {
        guard let group = groups[characteristic] else { return }
        item.selectMediaOptionAutomatically(in: group)
    }
}

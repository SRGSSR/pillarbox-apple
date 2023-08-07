//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

/// Manages the available media selections as well as the currently selected one.
struct MediaSelector: Equatable {
    static var empty: Self {
        self.init(groups: [:], selection: .init())
    }

    let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]
    let selection: AVMediaSelection

    var characteristics: Set<AVMediaCharacteristic> {
        Set(groups.keys)
    }

    func options(for characteristic: AVMediaCharacteristic) -> [AVMediaSelectionOption] {
        guard let group = groups[characteristic] else { return [] }
        return group.options
    }

    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionOption? {
        guard let group = groups[characteristic] else { return nil }
        switch MACaptionAppearanceGetDisplayType(.user) {
        case .alwaysOn:
            return selection.selectedMediaOption(in: group)
        default:
            return nil
        }
    }

    func select(mediaOption: AVMediaSelectionOption?, for characteristic: AVMediaCharacteristic, in item: AVPlayerItem?) {
        guard let item, let group = groups[characteristic] else { return }
        item.select(mediaOption, in: group)
    }

    func selectMediaOptionAutomatically(for characteristic: AVMediaCharacteristic, in item: AVPlayerItem?) {
        guard let item, let group = groups[characteristic] else { return }
        item.selectMediaOptionAutomatically(in: group)
    }
}

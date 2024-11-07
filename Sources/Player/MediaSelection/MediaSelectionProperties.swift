//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelectionProperties: Equatable {
    static let empty = Self(groups: [:], selection: nil, settingsChangeDate: .now)

    private let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]
    let selection: AVMediaSelection?
    private let settingsChangeDate: Date

    init(groups: [AVMediaCharacteristic: AVMediaSelectionGroup], selection: AVMediaSelection?, settingsChangeDate: Date) {
        self.groups = groups
        self.selection = selection
        self.settingsChangeDate = settingsChangeDate
    }
}

extension MediaSelectionProperties {
    var characteristics: Set<AVMediaCharacteristic> {
        Set(groups.keys)
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

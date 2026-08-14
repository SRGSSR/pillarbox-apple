//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MediaSelectionProperties: Equatable {
    static let empty = Self(provider: .empty, selection: nil, settingsChangeDate: .now)

    private let provider: MediaSelectionProvider
    let selection: AVMediaSelection?
    private let settingsChangeDate: Date

    init(provider: MediaSelectionProvider, selection: AVMediaSelection?, settingsChangeDate: Date) {
        self.provider = provider
        self.selection = selection
        self.settingsChangeDate = settingsChangeDate
    }
}

extension MediaSelectionProperties {
    var characteristics: Set<AVMediaCharacteristic> {
        provider.characteristics
    }

    func group(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? {
        provider.group(for: characteristic)
    }

    func selectedOption(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionOption? {
        guard let selection, let group = provider.group(for: characteristic) else { return nil }
        return selection.selectedMediaOption(in: group)
    }

    func reset(for characteristic: AVMediaCharacteristic, in item: AVPlayerItem) {
        guard let group = provider.group(for: characteristic) else { return }
        item.selectMediaOptionAutomatically(in: group)
    }
}

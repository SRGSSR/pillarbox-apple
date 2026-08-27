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

    func mediaSelector(for characteristic: AVMediaCharacteristic) -> MediaSelector? {
        guard let provider = provider.mediaSelectorProvider(for: characteristic) else { return nil }
        switch characteristic {
        case .audible:
            return AudibleMediaSelector(provider: provider)
        case .legible:
            return LegibleMediaSelector(provider: provider)
        default:
            return nil
        }
    }

    func selectedOption(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionOption? {
        provider.mediaSelectorProvider(for: characteristic)?.selectedMediaOption(in: selection)
    }

    func reset(for characteristic: AVMediaCharacteristic, in item: AVPlayerItem) {
        provider.mediaSelectorProvider(for: characteristic)?.selectMediaOptionAutomatically(for: item)
    }
}

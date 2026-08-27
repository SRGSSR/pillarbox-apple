//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

/// The default selector for legible options.
struct LegibleMediaSelector: MediaSelector {
    private let provider: MediaSelectorProvider

    init(provider: MediaSelectorProvider) {
        self.provider = provider
    }

    func mediaSelectionOptions() -> [MediaSelectionOption] {
        var options: [MediaSelectionOption] = [.automatic, .off]
        let preferredCaptioningOptions = AVMediaSelectionGroup.preferredCaptioningOptions(from: provider.options)
        options.append(
            contentsOf: AVMediaSelectionGroup.sortedMediaSelectionOptions(from: preferredCaptioningOptions)
                .map { .on($0) }
        )
        return options
    }

    func selectedMediaOption(
        in selection: AVMediaSelection?,
        with selectionCriteria: AVPlayerMediaSelectionCriteria?
    ) -> MediaSelectionOption {
        guard let preferredLanguages = selectionCriteria?.preferredLanguages, !preferredLanguages.isEmpty else {
            return persistedMediaOption(in: selection)
        }
        if let option = provider.selectedMediaOption(in: selection) {
            return .on(option)
        }
        else {
            return .off
        }
    }

    private func persistedMediaOption(in selection: AVMediaSelection?) -> MediaSelectionOption {
        switch MACaptionAppearanceGetDisplayType(.user) {
        case .alwaysOn:
            if let option = provider.selectedMediaOption(in: selection) {
                return .on(option)
            }
            else {
                return .off
            }
        case .automatic:
            return .automatic
        default:
            return .off
        }
    }

    func select(
        mediaOption: MediaSelectionOption,
        on item: AVPlayerItem,
        with selectionCriteria: AVPlayerMediaSelectionCriteria?
    ) -> AVPlayerMediaSelectionCriteria? {
        switch mediaOption {
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
            provider.selectMediaOptionAutomatically(for: item)
        case .off:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
            provider.selectMediaOptionAutomatically(for: item)
        case let .on(option):
            MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
            if let languageCode = option.languageCode {
                MACaptionAppearanceAddSelectedLanguage(.user, languageCode as CFString)
            }
            provider.select(option, for: item)
        }
        return nil
    }
}

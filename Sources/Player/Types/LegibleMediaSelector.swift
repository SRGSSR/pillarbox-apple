//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

struct LegibleMediaSelector: MediaSelector {
    let group: AVMediaSelectionGroup

    func mediaSelectionOptions() -> [MediaSelectionOption] {
        var options: [MediaSelectionOption] = [.automatic, .disabled]
        options.append(contentsOf: group.sortedOptions(withoutMediaCharacteristics: [.containsOnlyForcedSubtitles]))
        return options
    }

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption {
        switch MACaptionAppearanceGetDisplayType(.user) {
        case .alwaysOn:
            if let option = selection.selectedMediaOption(in: group) {
                return .enabled(option)
            }
            else {
                return .disabled
            }
        case .automatic:
            return .automatic
        default:
            return .disabled
        }
    }

    func select(
        mediaOption: MediaSelectionOption,
        otherSelectedOptions: [AVMediaCharacteristic: AVMediaSelectionOption],
        on item: AVPlayerItem
    ) {
        switch mediaOption {
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
            item.selectMediaOptionAutomatically(in: group)
        case .disabled:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
            item.select(forcedSubtitles(matching: otherSelectedOptions), in: group)
        case let .enabled(option):
            MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
            if let languageCode = option.languageCode {
                MACaptionAppearanceAddSelectedLanguage(.user, languageCode as CFString)
            }
            item.select(option, in: group)
        }
    }

    private func forcedSubtitles(matching otherSelectedOptions: [AVMediaCharacteristic: AVMediaSelectionOption]) -> AVMediaSelectionOption? {
        guard let audibleOption = otherSelectedOptions[.audible] else { return nil }
        return AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, withMediaCharacteristics: [.containsOnlyForcedSubtitles])
            .filter { $0.languageCode == audibleOption.languageCode }
            .first
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

struct LegibleMediaSelectionGroup: MediaSelectionGroup {
    let group: AVMediaSelectionGroup

    var options: [MediaSelectionOption] {
        var options: [MediaSelectionOption] = [.automatic, .disabled]
        options.append(contentsOf: group.sortedOptions(withoutMediaCharacteristics: [.containsOnlyForcedSubtitles]))
        return options
    }

    func forcedLegibleOption(matching selection: AVMediaSelection) -> AVMediaSelectionOption? {
        nil
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

    func select(mediaOption: MediaSelectionOption, in selection: AVMediaSelection, for item: AVPlayerItem) {
        switch mediaOption {
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
            item.selectMediaOptionAutomatically(in: group)
        case .disabled:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
            item.select(forcedLegibleOption(matching: selection), in: group)
        case let .enabled(option):
            MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
            if let languageCode = option.locale?.language.languageCode {
                MACaptionAppearanceAddSelectedLanguage(.user, languageCode.identifier as CFString)
            }
            item.select(option, in: group)
        }
    }
}

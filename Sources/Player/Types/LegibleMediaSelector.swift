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
        var options: [MediaSelectionOption] = [.automatic, .off]
        options.append(
            contentsOf: AVMediaSelectionGroup.sortedMediaSelectionOptions(
                from: group.options,
                withoutMediaCharacteristics: [.containsOnlyForcedSubtitles]
            )
            .map { .on($0) }
        )
        return options
    }

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption {
        switch MACaptionAppearanceGetDisplayType(.user) {
        case .alwaysOn:
            if let option = selection.selectedMediaOption(in: group) {
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

    func select(mediaOption: MediaSelectionOption, on item: AVPlayerItem) {
        switch mediaOption {
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
            item.selectMediaOptionAutomatically(in: group)
        case .off:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
            item.selectMediaOptionAutomatically(in: group)
        case let .on(option):
            MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
            if let languageCode = option.languageCode {
                MACaptionAppearanceAddSelectedLanguage(.user, languageCode as CFString)
            }
            item.select(option, in: group)
        }
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

struct MediaSelectionContext {
    static var empty: Self {
        self.init(groups: [:], selection: nil)
    }

    let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]
    let selection: AVMediaSelection?

    var characteristics: Set<AVMediaCharacteristic> {
        Set(groups.keys)
    }

    func mediaSelectionOptions(for characteristic: AVMediaCharacteristic) -> [MediaSelectionOption] {
        guard let group = groups[characteristic] else { return [] }
        switch characteristic {
        case .audible:
            let options = group.sortedOptions()
            return options.count > 1 ? options : []
        case .legible:
            var options: [MediaSelectionOption] = [.automatic, .disabled]
            options.append(contentsOf: group.sortedOptions(withoutMediaCharacteristics: [.containsOnlyForcedSubtitles]))
            return options

        default:
            return []
        }
    }

    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let selection, let group = groups[characteristic] else { return .disabled }
        switch characteristic {
        case .audible:
            if let option = selection.selectedMediaOption(in: group) {
                return .enabled(option)
            }
            else {
                return .disabled
            }
        case .legible:
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
        default:
            return .disabled
        }
    }

    func select(mediaOption: MediaSelectionOption, for characteristic: AVMediaCharacteristic, in item: AVPlayerItem?) {
        guard let item, let group = groups[characteristic] else { return }
        switch characteristic {
        case .audible:
            switch mediaOption {
            case let .enabled(option):
                item.select(option, in: group)
            default:
                break
            }
        case .legible:
            switch mediaOption {
            case .automatic:
                MACaptionAppearanceSetDisplayType(.user, .automatic)
                item.selectMediaOptionAutomatically(in: group)
            case .disabled:
                MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
                item.select(forcedLegibleOption(in: group), in: group)
            case let .enabled(option):
                MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
                if let languageCode = option.locale?.language.languageCode {
                    MACaptionAppearanceAddSelectedLanguage(.user, languageCode.identifier as CFString)
                }
                item.select(option, in: group)
            }
        default:
            break
        }
    }

    func activeMediaOption(for characteristic: AVMediaCharacteristic) -> AVMediaSelectionOption? {
        guard let selection, let group = groups[characteristic] else { return nil }
        return selection.selectedMediaOption(in: group)
    }

    private func forcedLegibleOption(in group: AVMediaSelectionGroup) -> AVMediaSelectionOption? {
        guard let selection, let audibleGroup = groups[.audible], let audibleOption = selection.selectedMediaOption(in: audibleGroup) else {
            return nil
        }
        return AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, withMediaCharacteristics: [.containsOnlyForcedSubtitles])
            .first { $0.locale?.language.languageCode == audibleOption.locale?.language.languageCode }
    }
}

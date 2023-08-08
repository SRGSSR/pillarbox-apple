//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

public enum MediaSelectionOption: Hashable {
    case none
    case automatic
    case alwaysOn(AVMediaSelectionOption)

    public var displayName: String {
        switch self {
        case .none:
            return "Off"
        case .automatic:
            return "Auto (Recommended)"
        case let .alwaysOn(option):
            return option.displayName
        }
    }
}

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

    func options(for characteristic: AVMediaCharacteristic) -> [MediaSelectionOption] {
        guard let group = groups[characteristic] else { return [] }
        var options = [MediaSelectionOption]()
        if characteristic == .legible {
            options.append(contentsOf: [.automatic, .none])
        }
        options.append(contentsOf: group.options.map { .alwaysOn($0) })
        return options
    }

    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let group = groups[characteristic] else { return .none }
        if characteristic == .legible {
            switch MACaptionAppearanceGetDisplayType(.user) {
            case .alwaysOn:
                if let option = selection.selectedMediaOption(in: group) {
                    return .alwaysOn(option)
                }
                else {
                    return .none
                }
            case .automatic:
                return .automatic
            default:
                return .none
            }
        }
        else {
            if let option = selection.selectedMediaOption(in: group) {
                return .alwaysOn(option)
            }
            else {
                return .none
            }
        }
    }

    func select(mediaOption: MediaSelectionOption, for characteristic: AVMediaCharacteristic, in item: AVPlayerItem?) {
        guard let item, let group = groups[characteristic] else { return }
        switch mediaOption {
        case .none:
            if characteristic == .legible {
                MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
            }
            item.select(nil, in: group)
        case .automatic:
            if characteristic == .legible {
                MACaptionAppearanceSetDisplayType(.user, .automatic)
            }
            item.selectMediaOptionAutomatically(in: group)
        case let .alwaysOn(option):
            if characteristic == .legible {
                MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
                if let languageCode = option.locale?.language.languageCode {
                    MACaptionAppearanceAddSelectedLanguage(.user, languageCode.identifier as CFString)
                }
            }
            item.select(option, in: group)
        }
    }
}

extension MediaSelector: CustomDebugStringConvertible {
    var debugDescription: String {
        groups.map { characteristic, _ in
            let option = selectedMediaOption(for: characteristic)
            return "\(characteristic.rawValue) = \(option.displayName)"
        }.joined(separator: ", ")
    }
}

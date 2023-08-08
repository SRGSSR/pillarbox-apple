//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//
import AVFoundation
import MediaAccessibility

public enum MediaSelectionOption: Hashable {
    case automatic
    case disabled
    case enabled(AVMediaSelectionOption)

    public var displayName: String {
        switch self {
        case .automatic:
            return "Auto (Recommended)"
        case .disabled:
            return "Off"
        case let .enabled(option):
            return option.displayName
        }
    }
}

protocol MediaSelectionGroup {
    var options: [MediaSelectionOption] { get }

    init(group: AVMediaSelectionGroup)

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption
    func select(mediaOption: MediaSelectionOption, in item: AVPlayerItem)
}

struct AudibleGroup: MediaSelectionGroup {
    let group: AVMediaSelectionGroup

    var options: [MediaSelectionOption] {
        guard group.options.count > 1 else { return [] }
        return group.options.map { .enabled($0) }
    }

    func selectedMediaOption(in selection: AVMediaSelection) -> MediaSelectionOption {
        if let option = selection.selectedMediaOption(in: group) {
            return .enabled(option)
        }
        else {
            return .disabled
        }
    }

    func select(mediaOption: MediaSelectionOption, in item: AVPlayerItem) {
        switch mediaOption {
        case let .enabled(option):
            item.select(option, in: group)
        default:
            item.select(nil, in: group)
        }
    }
}

struct LegibleGroup: MediaSelectionGroup {
    let group: AVMediaSelectionGroup

    var options: [MediaSelectionOption] {
        var options: [MediaSelectionOption] = [.automatic, .disabled]
        options.append(contentsOf: group.options.map { .enabled($0) })
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

    func select(mediaOption: MediaSelectionOption, in item: AVPlayerItem) {
        switch mediaOption {
        case .disabled:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
            item.select(nil, in: group)
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
            item.selectMediaOptionAutomatically(in: group)
        case let .enabled(option):
            MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
            if let languageCode = option.locale?.language.languageCode {
                MACaptionAppearanceAddSelectedLanguage(.user, languageCode.identifier as CFString)
            }
            item.select(option, in: group)
        }
    }
}

/// Manages the available media selections as well as the currently selected one.
struct MediaSelector {
    static var empty: Self {
        self.init(groups: [:], selection: .init())
    }

    let groups: [AVMediaCharacteristic: any MediaSelectionGroup]
    let selection: AVMediaSelection

    var characteristics: Set<AVMediaCharacteristic> {
        Set(groups.keys)
    }

    init(groups: [AVMediaCharacteristic: AVMediaSelectionGroup], selection: AVMediaSelection) {
        self.groups = .init(uniqueKeysWithValues: groups.compactMap { characteristic, group in
            switch characteristic {
            case .legible:
                return (characteristic, LegibleGroup(group: group))
            case .audible:
                return (characteristic, AudibleGroup(group: group))
            default:
                return nil
            }
        })
        self.selection = selection
    }

    func options(for characteristic: AVMediaCharacteristic) -> [MediaSelectionOption] {
        guard let group = groups[characteristic] else { return [] }
        return group.options
    }

    func selectedMediaOption(for characteristic: AVMediaCharacteristic) -> MediaSelectionOption {
        guard let group = groups[characteristic] else { return .disabled }
        return group.selectedMediaOption(in: selection)
    }

    func select(mediaOption: MediaSelectionOption, for characteristic: AVMediaCharacteristic, in item: AVPlayerItem?) {
        guard let item, let group = groups[characteristic] else { return }
        group.select(mediaOption: mediaOption, in: item)
    }
}

extension MediaSelector: CustomDebugStringConvertible {
    var debugDescription: String {
        groups
            .map { characteristic, _ in
                let option = selectedMediaOption(for: characteristic)
                return "\(characteristic.rawValue) = \(option.displayName)"
            }
            .joined(separator: ", ")
    }
}

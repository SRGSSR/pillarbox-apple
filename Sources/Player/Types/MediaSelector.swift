//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//
import AVFoundation
import MediaAccessibility

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
                return (characteristic, LegibleSelectionGroup(group: group))
            case .audible:
                return (characteristic, AudibleSelectionGroup(group: group))
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

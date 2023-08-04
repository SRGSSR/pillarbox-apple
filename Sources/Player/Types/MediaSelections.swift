//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A container for available media selections.
///
/// Media selections generally describe possible media-related user selections like subtitles or audio tracks, most
/// notably.
public struct MediaSelections: Equatable {
    static var empty: Self {
        self.init(groups: [:])
    }

    let groups: [AVMediaCharacteristic: AVMediaSelectionGroup]

    /// The available media characteristics.
    public var characteristics: [AVMediaCharacteristic] {
        Array(groups.keys)
    }

    /// The available options matching some characteristic.
    ///
    /// - Parameter characteristic: The characteristic to request options for.
    /// - Returns: The available options.
    public func options(withMediaCharacteristic characteristic: AVMediaCharacteristic) -> [AVMediaSelectionOption] {
        guard let group = groups[characteristic] else { return [] }
        return group.options
    }
}

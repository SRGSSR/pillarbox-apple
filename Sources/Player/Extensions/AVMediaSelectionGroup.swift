//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVMediaSelectionGroup {
    /// Returns media selection options where options with the provided characteristics are preferred.
    ///
    /// When several options have the same language code in the original list, those which have the provided media
    /// characteristics are preferred.
    static func preferredMediaSelectionOptions(
        from options: [AVMediaSelectionOption],
        withMediaCharacteristics characteristics: [AVMediaCharacteristic]
    ) -> [AVMediaSelectionOption] {
        let withOptions = Dictionary(grouping: mediaSelectionOptions(from: options, withMediaCharacteristics: characteristics)) { option in
            option.languageCode
        }
        return Dictionary(grouping: options) { option in
            option.languageCode
        }
        .merging(withOptions) { _, new in new }
        .values
        .flatMap(\.self)
    }

    /// Returns media selection options where options without the provided characteristics are preferred.
    ///
    /// When several options have the same language code in the original list, those which don't have the provided media
    /// characteristics are preferred.
    static func preferredMediaSelectionOptions(
        from options: [AVMediaSelectionOption],
        withoutMediaCharacteristics characteristics: [AVMediaCharacteristic]
    ) -> [AVMediaSelectionOption] {
        let withoutOptions = Dictionary(grouping: mediaSelectionOptions(from: options, withoutMediaCharacteristics: characteristics)) { option in
            option.languageCode
        }
        return Dictionary(grouping: options) { option in
            option.languageCode
        }
        .merging(withoutOptions) { _, new in new }
        .values
        .flatMap(\.self)
    }

    static func sortedMediaSelectionOptions(from options: [AVMediaSelectionOption]) -> [AVMediaSelectionOption] {
        options.sorted(by: <)
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaAccessibility

func MAPreferredMediaCharacteristics(for characteristic: AVMediaCharacteristic) -> [AVMediaCharacteristic] {
    switch characteristic {
    case .audible:
        return MAAudibleMediaCopyPreferredCharacteristics().takeRetainedValue() as? [AVMediaCharacteristic] ?? []
    case .legible:
        return MACaptionAppearanceCopyPreferredCaptioningMediaCharacteristics(.user).takeRetainedValue() as? [AVMediaCharacteristic] ?? []
    default:
        return []
    }
}

func MAPreferredLanguages(for characteristic: AVMediaCharacteristic) -> [String] {
    switch characteristic {
    case .legible:
        return MACaptionAppearanceCopySelectedLanguages(.user).takeUnretainedValue() as? [String] ?? []
    default:
        return []
    }
}

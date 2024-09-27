//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SpriteKit

/// Lightweight video node subclass to disable automatic un-pause when waking the application from the background.
final class VideoNode: SKVideoNode {
    private static let _playerKey = "12_34p9l3a23y4e5r76".components(separatedBy: .decimalDigits).joined(separator: "")

    override var isPaused: Bool {
        get {
            super.isPaused
        }
        set {}
    }

    deinit {
        if #available(iOS 18, tvOS 18, *) {
            setValue(nil, forKey: Self._playerKey)
        }
    }
}

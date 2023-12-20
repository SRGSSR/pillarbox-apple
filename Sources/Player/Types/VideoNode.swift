//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SpriteKit

/// Lightweight video node subclass to disable automatic un-pause when waking the application from the background.
final class VideoNode: SKVideoNode {
    override var isPaused: Bool {
        get {
            super.isPaused
        }
        set {}
    }
}

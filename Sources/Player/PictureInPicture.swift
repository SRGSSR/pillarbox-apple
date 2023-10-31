//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

/// A service for managing Picture in Picture.
public final class PictureInPicture: NSObject {
    /// The shared service instance.
    public static let shared = PictureInPicture()

    private var controller: AVPictureInPictureController?

    var playerLayer: AVPlayerLayer? {
        get {
            controller?.playerLayer
        }
        set {
            if let newValue {
                guard controller?.playerLayer != newValue else { return }
                controller = AVPictureInPictureController(playerLayer: newValue)
            }
            else {
                controller = nil
            }
        }
    }

    override private init() {
        super.init()
    }

    /// Starts Picture in Picture programmatically.
    ///
    /// Only begin PiP playback in response to explicit user interaction. The App Store review team rejects apps that
    /// fail to follow this requirement.
    public func start() {
        controller?.startPictureInPicture()
    }

    /// Stops Picture in Picture programmatically.
    public func stop() {
        controller?.stopPictureInPicture()
    }
}

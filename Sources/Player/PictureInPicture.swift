//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

public final class PictureInPicture: NSObject {
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

    public func start() {
        controller?.startPictureInPicture()
    }

    public func stop() {
        controller?.stopPictureInPicture()
    }
}

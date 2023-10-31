//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

final class PictureInPicture: NSObject {
    static let shared = PictureInPicture()

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

    func start() {
        controller?.startPictureInPicture()
    }

    func stop() {
        controller?.stopPictureInPicture()
    }
}

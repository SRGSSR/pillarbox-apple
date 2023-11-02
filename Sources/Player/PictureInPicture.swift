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
            guard controller?.playerLayer != newValue else { return }
            controller = newValue.flatMap { AVPictureInPictureController(playerLayer: $0) }
            controller?.delegate = self
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

extension PictureInPicture: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("--> will start")
    }

    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("--> did start")
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("--> restore")
        completionHandler(true)
    }

    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("--> will stop")
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("--> did stop")
    }
}

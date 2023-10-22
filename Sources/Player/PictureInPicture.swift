//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

public class PictureInPicture: NSObject, ObservableObject {
    private var controller: AVPictureInPictureController?

    public var willStartPictureInPicture: (() -> Void)?
    public var didStartPictureInPicture: (() -> Void)?
    public var restorePictureInPicture: ((_ completion: @escaping (Bool) -> Void) -> Void)?

    public var currentLayer: AVPlayerLayer? {
        controller?.playerLayer
    }

    public func start() {
        guard controller?.isPictureInPicturePossible == true else { print("--> Can't start picture in picture"); return }
        controller?.startPictureInPicture()
        print("--> Start \(Unmanaged.passUnretained(self.currentLayer!).toOpaque())")
    }

    func attach(playerLayer: AVPlayerLayer) {
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }
        guard controller == nil else { return }
        self.controller = AVPictureInPictureController(playerLayer: playerLayer)
        self.controller?.delegate = self
        print("--> attach \(Unmanaged.passUnretained(self.currentLayer!).toOpaque())")
    }
}

extension PictureInPicture: AVPictureInPictureControllerDelegate {
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("--> Failed to start: \(Unmanaged.passUnretained(pictureInPictureController.playerLayer).toOpaque()) - \(error)")
    }

    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async {
            self.willStartPictureInPicture?()
        }
        print("--> Will start: \(Unmanaged.passUnretained(pictureInPictureController.playerLayer).toOpaque())")
    }

    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async {
            self.didStartPictureInPicture?()
        }
        print("--> Did start: \(Unmanaged.passUnretained(pictureInPictureController.playerLayer).toOpaque())")
    }

    public func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        DispatchQueue.main.async {
            self.restorePictureInPicture?(completionHandler)
        }
        print("--> Restore: \(Unmanaged.passUnretained(pictureInPictureController.playerLayer).toOpaque())")
    }
}

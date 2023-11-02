//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

public protocol PictureInPictureDelegate: AnyObject {
    func pictureInPictureWillStart(_ pictureInPicture: PictureInPicture)
    func pictureInPictureDidStart(_ pictureInPicture: PictureInPicture)
    func pictureInPictureController(_ pictureInPicture: PictureInPicture, failedToStartWithError error: Error)
    func pictureInPicture(
        _ pictureInPicture: PictureInPicture,
        restoreUserInterfaceForStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    )
    func pictureInPictureWillStop(_ pictureInPicture: PictureInPicture)
    func pictureInPictureDidStop(_ pictureInPicture: PictureInPicture)
}

public final class PictureInPicture: NSObject {
    public static let shared = PictureInPicture()

    @Published public private(set) var isActive = false

    public weak var delegate: PictureInPictureDelegate?

    private var controller: AVPictureInPictureController? {
        didSet {
            isActive = controller?.isPictureInPictureActive ?? false
        }
    }

    private(set) var playerLayer: AVPlayerLayer? {
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

    func register(for playerLayer: AVPlayerLayer) {
        self.playerLayer = playerLayer
    }

    func unregister(for playerLayer: AVPlayerLayer) {
        guard self.playerLayer == playerLayer, !isActive else { return }
        self.playerLayer = nil
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
        isActive = true
        delegate?.pictureInPictureWillStart(self)
    }

    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        delegate?.pictureInPictureDidStart(self)
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        delegate?.pictureInPictureController(self, failedToStartWithError: error)
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        delegate?.pictureInPicture(self, restoreUserInterfaceForStopWithCompletionHandler: completionHandler)
    }

    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        delegate?.pictureInPictureWillStop(self)
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = false
        delegate?.pictureInPictureDidStop(self)
    }
}

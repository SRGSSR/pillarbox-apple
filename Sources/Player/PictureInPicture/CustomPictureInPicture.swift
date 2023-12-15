//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine

/// Manages Picture in Picture for `VideoView` instances.
final class CustomPictureInPicture: NSObject {
    @Published private(set) var isPossible = false
    @Published private(set) var isActive = false
    @Published private(set) var isInAppPossible = false

    @objc private dynamic var controller: AVPictureInPictureController?
    weak var delegate: PictureInPictureDelegate?

    private var deferredCleanup: (() -> Void)?
    private var referenceCount = 0
    private var pendingReferenceCount = 0

    var playerLayer: AVPlayerLayer? {
        controller?.playerLayer
    }

    override init() {
        super.init()
        configureIsPossiblePublisher()
    }

    func start() {
        controller?.startPictureInPicture()
    }

    func stop() {
        controller?.stopPictureInPicture()
    }

    func toggle() {
        if isActive {
            stop()
        }
        else {
            start()
        }
    }

    func acquire(for playerLayer: AVPlayerLayer?) {
        guard let playerLayer else {
            pendingReferenceCount += 1
            return
        }

        if controller?.playerLayer === playerLayer {
            referenceCount += 1
        }
        else {
            controller = AVPictureInPictureController(playerLayer: playerLayer)
            if let controller {
                controller.delegate = self
                referenceCount = pendingReferenceCount + 1
                pendingReferenceCount = 0
            }
            else {
                referenceCount = 0
            }
        }
    }

    func relinquish(for playerLayer: AVPlayerLayer?) {
        guard let playerLayer else {
            pendingReferenceCount -= 1
            return
        }

        guard controller?.playerLayer === playerLayer else { return }
        referenceCount -= 1
        guard referenceCount == 0 else { return }

        pendingReferenceCount = 0
        controller = nil

        // Wait until the next run loop to avoid cleanup possibly triggering body updates for discarded views.
        DispatchQueue.main.async {
            self.clean()
        }
    }

    func update(with player: AVPlayer) {
        guard let currentPlayer = playerLayer?.player, currentPlayer !== player else { return }
        clean()
    }

    private func clean() {
        deferredCleanup?()
        deferredCleanup = nil
    }

    private func configureIsPossiblePublisher() {
        publisher(for: \.controller)
            .map { controller in
                guard let controller else { return Just(false).eraseToAnyPublisher() }
                return controller.publisher(for: \.isPictureInPicturePossible).eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$isPossible)
    }

    func restoreFromInAppPictureInPictureWithSetup(perform setup: @escaping () -> Void) {
        isInAppPossible = true
        acquire(for: playerLayer)
        stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: setup)
    }

    func enableInAppPictureInPictureWithCleanup(perform cleanup: @escaping () -> Void) {
        isInAppPossible = false

        if referenceCount == 0 {
            cleanup()
        }
        else {
            deferredCleanup = cleanup
            relinquish(for: playerLayer)
        }
    }
}

extension CustomPictureInPicture: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = true
        acquire(for: pictureInPictureController.playerLayer)
        delegate?.pictureInPictureWillStart()
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        delegate?.pictureInPictureDidStart()
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        delegate?.pictureInPictureControllerFailedToStart(with: error)
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        delegate?.pictureInPictureRestoreUserInterfaceForStop(with: completionHandler)
    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = false
        delegate?.pictureInPictureWillStop()
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        relinquish(for: pictureInPictureController.playerLayer)
        delegate?.pictureInPictureDidStop()
    }
}

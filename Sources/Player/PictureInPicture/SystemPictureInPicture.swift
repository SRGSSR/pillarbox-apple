//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

/// Manages Picture in Picture for `SystemVideoView` instances.
final class SystemPictureInPicture: NSObject {
    private(set) var isActive = false

    var playerViewController: AVPlayerViewController?
    weak var delegate: PictureInPictureDelegate?

    private var deferredCleanup: (() -> Void)?
    private var referenceCount = 0

    func stop() {
        playerViewController?.stopPictureInPicture()
    }

    func acquire(for controller: AVPlayerViewController) {
        if controller === playerViewController {
            referenceCount += 1
        }
        else {
            playerViewController = controller
            playerViewController?.delegate = self
            referenceCount = 1
        }
    }

    func relinquish(for controller: AVPlayerViewController) {
        guard controller === playerViewController else { return }
        referenceCount -= 1

        guard referenceCount == 0 else { return }
        playerViewController = nil

        // Wait until the next run loop to avoid cleanup possibly triggering body updates for discarded views.
        DispatchQueue.main.async {
            self.clean()
        }
    }

    func update(with player: AVPlayer) {
        guard let currentPlayer = playerViewController?.player, currentPlayer !== player else { return }
        clean()
    }

    private func clean() {
        deferredCleanup?()
        deferredCleanup = nil
    }

    func restoreFromInAppPictureInPictureWithSetup(perform setup: @escaping () -> Void) {
        guard let playerViewController else { return }
        acquire(for: playerViewController)
        stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: setup)
    }

    func enableInAppPictureInPictureWithCleanup(perform cleanup: @escaping () -> Void) {
        if referenceCount == 0 {
            cleanup()
        }
        else {
            deferredCleanup = cleanup
            if let playerViewController {
                relinquish(for: playerViewController)
            }
        }
    }
}

extension SystemPictureInPicture: AVPlayerViewControllerDelegate {
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        isActive = true
        acquire(for: playerViewController)
        delegate?.pictureInPictureWillStart()
    }

    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        delegate?.pictureInPictureDidStart()
    }

    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        delegate?.pictureInPictureControllerFailedToStart(with: error)
    }

    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        delegate?.pictureInPictureRestoreUserInterfaceForStop(with: completionHandler)
    }

    func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        isActive = true
        delegate?.pictureInPictureWillStop()
    }

    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        relinquish(for: playerViewController)
        delegate?.pictureInPictureDidStop()
    }

#if os(iOS)
    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
        acquire(for: playerViewController)
    }

    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
        relinquish(for: playerViewController)
    }
#endif
}

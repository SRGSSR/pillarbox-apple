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
        if referenceCount == 0 {
            playerViewController = nil
        }
    }

    func onAppear(with player: AVPlayer, isPictureInPictureSupported: Bool) {
        if !isPictureInPictureSupported {
            detach(with: player)
        }
    }

    /// Avoid unnecessary pauses when transitioning via Picture in Picture to a view which does not support
    /// it.
    ///
    /// See https://github.com/SRGSSR/pillarbox-apple/issues/612 for more information.
    func detach(with player: AVPlayer) {
        guard playerViewController?.player === player else { return }
        playerViewController?.player = nil
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
        if let delegate {
            delegate.pictureInPictureRestoreUserInterfaceForStop(with: completionHandler)
        }
        else {
            completionHandler(true)
        }
    }

    func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        isActive = false
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

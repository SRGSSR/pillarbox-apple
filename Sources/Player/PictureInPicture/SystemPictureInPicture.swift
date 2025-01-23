//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import OrderedCollections

private class PlayerViewController: AVPlayerViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // We can use fine-grained presentation information to avoid stopping Picture in Picture when enabled
        // from maximized layout.
        if isMovingToParentOrBeingPresented() {
            PictureInPicture.shared.system.stop()
        }
    }
}

/// Manages Picture in Picture for `SystemVideoView` instances.
final class SystemPictureInPicture: NSObject {
    private(set) var isActive = false

    private var playerViewController: AVPlayerViewController?
    private var hostViewControllers: OrderedSet<PictureInPictureHostViewController> = []

    weak var delegate: PictureInPictureDelegate?
    private var referenceCount = 0

    func stop() {
        playerViewController?.stopPictureInPicture()
    }

    func makeHostViewController(for player: Player) -> PictureInPictureHostViewController {
        let hostViewController = PictureInPictureHostViewController()
        hostViewControllers.append(hostViewController)
        hostViewController.addViewController(makePlayerViewController(for: player))
        return hostViewController
    }

    private func makePlayerViewController(for player: Player) -> AVPlayerViewController {
        if let playerViewController, playerViewController.player == player.queuePlayer {
            if let parent = playerViewController.parent as? PictureInPictureHostViewController {
                parent.addViewController(playerViewController.duplicate())
            }
            return playerViewController
        }
        else {
            let playerViewController = PlayerViewController()
            playerViewController.allowsPictureInPicturePlayback = true
#if os(iOS)
            playerViewController.updatesNowPlayingInfoCenter = false
#endif
            playerViewController.delegate = self
            playerViewController.player = player.queuePlayer
            return playerViewController
        }
    }

    func dismantleHostViewController(_ hostViewController: PictureInPictureHostViewController) {
        hostViewControllers.remove(hostViewController)
        if !isActive && playerViewController == hostViewController.playerViewController {
            if let lastHostView = hostViewControllers.last {
                playerViewController = lastHostView.playerViewController
            }
            else {
                playerViewController = nil
            }
        }
    }

    func onAppear(with player: AVPlayer, supportsPictureInPicture: Bool) {
        if !supportsPictureInPicture {
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
        self.playerViewController = playerViewController
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
        delegate?.pictureInPictureDidStop()

        // Ensure proper resource cleanup if PiP is closed from the overlay without matching video view visible.
        if hostViewControllers.isEmpty {
            self.playerViewController = nil
        }
        // Wire the PiP controller to a valid source if the restored state is not bound to the player involved in
        // the restoration.
        else if !hostViewControllers.map(\.playerViewController).contains(self.playerViewController) {
            self.playerViewController = hostViewControllers.last?.playerViewController
        }
    }
}

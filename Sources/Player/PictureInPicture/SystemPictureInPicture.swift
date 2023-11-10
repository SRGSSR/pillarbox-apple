//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import SwiftUI

/// Manages Picture in Picture.
public final class SystemPictureInPicture: NSObject {
    static let shared = SystemPictureInPicture()

    @Published private(set) var isPossible = false
    @Published private(set) var isActive = false
    @Published private(set) var isInAppEnabled = false

    private weak var delegate: PictureInPictureLifeCycle?
    private var cleanup: (() -> Void)?

    @objc private dynamic var controller: AVPictureInPictureController?
    private var referenceCount = 0

    var playerViewController: AVPlayerViewController?

    var playerLayer: AVPlayerLayer? {
        controller?.playerLayer
    }

    override private init() {
        super.init()
        configureIsPossiblePublisher()
    }

    /// Sets a delegate for Picture in Picture.
    ///
    /// In-app Picture in Picture support requires your application to setup a delegate so a playback view supporting
    /// Picture in Picture can be dismissed and restored at a later time, letting users navigate your app while
    /// playback continues in the Picture in Picture overlay.
    public static func setDelegate(_ delegate: PictureInPictureLifeCycle) {
        shared.delegate = delegate
    }
}

// MARK: Acquire & Relinquish for AVPlayerLayer

extension SystemPictureInPicture {
    func acquire(for playerLayer: AVPlayerLayer) {
        if controller?.playerLayer === playerLayer {
            referenceCount += 1
        }
        else {
            controller = AVPictureInPictureController(playerLayer: playerLayer)
            controller?.delegate = self
            referenceCount = 1
        }
    }

    func relinquish(for playerLayer: AVPlayerLayer) {
        guard controller?.playerLayer === playerLayer else { return }
        referenceCount -= 1
        if referenceCount == 0 {
            self.controller = nil

            // Wait until the next run loop to avoid cleanup possibly triggering body updates for discarded views.
            DispatchQueue.main.async {
                self.clean()
            }
        }
    }

    func clean() {
        cleanup?()
        cleanup = nil
    }
}

// MARK: Acquire & Relinquish for AVPlayerViewController

extension SystemPictureInPicture {
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
            self.playerViewController = nil

            // Wait until the next run loop to avoid cleanup possibly triggering body updates for discarded views.
            DispatchQueue.main.async {
                self.clean()
            }
        }
    }
}

public extension SystemPictureInPicture {
    /// Restores from in-app Picture in Picture playback.
    ///
    /// UIKit view controllers must call this method on view appearance to ensure playback can be automatically restored
    /// from Picture in Picture.
    func restoreFromInAppPictureInPicture() {
        if let playerLayer {
            acquire(for: playerLayer)
        }
        if let playerViewController {
            acquire(for: playerViewController)
        }
        isInAppEnabled = true
    }

    /// Enables in-app Picture in Picture playback.
    ///
    /// UIKit view controllers must call this method on view disappearance to register a cleanup closure which will
    /// ensure resources which must be kept alive during Picture in Picture are properly cleaned up when Picture
    /// in Picture does not require them anymore.
    func enableInAppPictureInPictureWithCleanup(perform cleanup: @escaping () -> Void) {
        if referenceCount != 0 {
            self.cleanup = cleanup
        }
        else {
            cleanup()
            self.cleanup = nil
        }
        if let playerLayer {
            relinquish(for: playerLayer)
        }
        if let playerViewController {
            relinquish(for: playerViewController)
        }
        isInAppEnabled = false
    }
}

private extension SystemPictureInPicture {
    func configureIsPossiblePublisher() {
        publisher(for: \.controller)
            .map { controller in
                guard let controller else { return Just(false).eraseToAnyPublisher() }
                return controller.publisher(for: \.isPictureInPicturePossible).eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$isPossible)
    }
}

extension SystemPictureInPicture {
    func start() {
        controller?.startPictureInPicture()
    }

    func stop() {
        if let controller {
            controller.stopPictureInPicture()
        }
    }

    func toggle() {
        if isActive {
            stop()
        }
        else {
            start()
        }
    }
}

// MARK: Delegate for Picture in Picture controller

extension SystemPictureInPicture: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = true
        acquire(for: pictureInPictureController.playerLayer)
        delegate?.pictureInPictureWillStart()
    }

    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        delegate?.pictureInPictureDidStart()
    }

    public func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        delegate?.pictureInPictureControllerFailedToStart(with: error)
    }

    public func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        delegate?.pictureInPictureRestoreUserInterfaceForStop(with: completionHandler)
    }

    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = false
        delegate?.pictureInPictureWillStop()
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        relinquish(for: pictureInPictureController.playerLayer)
        delegate?.pictureInPictureDidStop()
    }
}

// MARK: Delegate for player view controller

extension SystemPictureInPicture: AVPlayerViewControllerDelegate {
    public func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        isActive = true
        acquire(for: playerViewController)
        delegate?.pictureInPictureWillStart()
    }

    public func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        delegate?.pictureInPictureDidStart()
    }

    public func playerViewController(
        _ playerViewController: AVPlayerViewController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        delegate?.pictureInPictureControllerFailedToStart(with: error)
    }

    public func playerViewController(
        _ playerViewController: AVPlayerViewController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        delegate?.pictureInPictureRestoreUserInterfaceForStop(with: completionHandler)
    }

    public func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        isActive = false
        delegate?.pictureInPictureWillStop()
    }

    public func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        relinquish(for: playerViewController)
        delegate?.pictureInPictureDidStop()
    }

#if os(iOS)
    public func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
        acquire(for: playerViewController)
    }

    public func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
        relinquish(for: playerViewController)
    }
#endif
}

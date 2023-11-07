//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import SwiftUI

/// A protocol describing the Picture in Picture life cycle.
///
/// Applications which require in-app Picture in Picture support must setup a delegate and rely on the Picture in
/// Picture life cycle to dismiss and restore views as required.
public protocol PictureInPictureDelegate: AnyObject {
    /// Called when Picture in Picture is about to start.
    ///
    /// Use this method to save which view was presented before dismissing it. Use the saved view for later restoration.
    func pictureInPictureWillStart(_ pictureInPicture: PictureInPicture)

    /// Called when Picture in Picture has started.
    func pictureInPictureDidStart(_ pictureInPicture: PictureInPicture)

    /// Called when Picture in Picture failed to start.
    func pictureInPictureController(_ pictureInPicture: PictureInPicture, failedToStartWithError error: Error)

    /// Called when the user interface will be restored from Picture in Picture.
    ///
    /// Use this method to present the original view which Picture in Picture was initiated from. The completion handler
    /// must be called at the very end of the restoration with `true` to notify the system that restoration is complete.
    func pictureInPicture(
        _ pictureInPicture: PictureInPicture,
        restoreUserInterfaceForStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    )

    /// Called when Picture in Picture is about to stop.
    func pictureInPictureWillStop(_ pictureInPicture: PictureInPicture)

    /// Called when Picture in Picture has stopped.
    func pictureInPictureDidStop(_ pictureInPicture: PictureInPicture)
}

/// Manages Picture in Picture.
public final class PictureInPicture: NSObject {
    static let shared = PictureInPicture()

    @Published private(set) var isPossible = false
    @Published private(set) var isActive = false
    @Published private(set) var isInAppEnabled = false

    private weak var delegate: PictureInPictureDelegate?
    private var cleanup: (() -> Void)?

    @objc private dynamic var controller: AVPictureInPictureController?
    private var referenceCount = 0

    private var playerViewController: AVPlayerViewController?

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
    public static func setDelegate(_ delegate: PictureInPictureDelegate) {
        shared.delegate = delegate
    }
}

// MARK: Acquire & Relinquish for AVPlayerLayer

extension PictureInPicture {
    func acquire(for playerLayer: AVPlayerLayer) {
        if let controller {
            guard controller.playerLayer == playerLayer else { return }
            referenceCount += 1
        }
        else {
            controller = AVPictureInPictureController(playerLayer: playerLayer)
            if let controller {
                controller.delegate = self
                referenceCount = 1
            }
        }
    }

    func relinquish(for playerLayer: AVPlayerLayer) {
        guard let controller, controller.playerLayer === playerLayer else { return }
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

extension PictureInPicture {
    func acquire(for controller: AVPlayerViewController) {
        playerViewController = controller
        playerViewController?.delegate = self
        referenceCount = 1
    }

    func relinquish(for controller: AVPlayerViewController) {
    }
}

extension PictureInPicture: AVPlayerViewControllerDelegate {
    public func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
    }
    public func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
    }
    public func playerViewController(
        _ playerViewController: AVPlayerViewController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
    }
    public func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
    }
    public func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
    }
    public func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
    }
}

public extension PictureInPicture {
    /// Restores from in-app Picture in Picture playback.
    ///
    /// UIKit view controllers must call this method on view appearance to ensure playback can be automatically restored
    /// from Picture in Picture.
    func restoreFromInAppPictureInPicture() {
        if let playerLayer {
            acquire(for: playerLayer)
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
        isInAppEnabled = false
    }
}

private extension PictureInPicture {
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

extension PictureInPicture {
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
}

extension PictureInPicture: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = true
        acquire(for: pictureInPictureController.playerLayer)
        delegate?.pictureInPictureWillStart(self)
    }

    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        delegate?.pictureInPictureDidStart(self)
    }

    public func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        delegate?.pictureInPictureController(self, failedToStartWithError: error)
    }

    public func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        delegate?.pictureInPicture(self, restoreUserInterfaceForStopWithCompletionHandler: completionHandler)
    }

    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = false
        delegate?.pictureInPictureWillStop(self)
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        relinquish(for: pictureInPictureController.playerLayer)
        delegate?.pictureInPictureDidStop(self)
    }
}

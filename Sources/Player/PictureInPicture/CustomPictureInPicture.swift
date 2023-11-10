//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import SwiftUI

/// Manages Picture in Picture for `VideoView` instances.
public final class CustomPictureInPicture: NSObject {
    static let shared = CustomPictureInPicture()

    @Published private(set) var isPossible = false
    @Published private(set) var isActive = false
    @Published private(set) var isInAppEnabled = false

    private weak var delegate: PictureInPictureLifeCycle?
    private var cleanup: (() -> Void)?

    @objc private dynamic var controller: AVPictureInPictureController?
    private var referenceCount = 0

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

    func restoreFromInAppPictureInPicture() {
        if let playerLayer {
            acquire(for: playerLayer)
        }
        isInAppEnabled = true
    }

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

extension CustomPictureInPicture: AVPictureInPictureControllerDelegate {
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

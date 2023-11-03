//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import SwiftUI

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
    static let shared = PictureInPicture()

    @Published private(set) var isPossible = false
    @Published private(set) var isActive = false

    public weak var delegate: PictureInPictureDelegate?
    private var release: (() -> Void)?

    @objc private dynamic var controller: AVPictureInPictureController?
    private var referenceCount = 0

    var playerLayer: AVPlayerLayer? {
        controller?.playerLayer
    }

    override private init() {
        super.init()
        configureIsPossiblePublisher()
    }

    public static func setDelegate(_ delegate: PictureInPictureDelegate) {
        shared.delegate = delegate
    }
}

extension PictureInPicture {
    func acquire() {
        guard let playerLayer else { return }
        acquire(for: playerLayer)
    }

    func relinquish() {
        guard let playerLayer else { return }
        relinquish(for: playerLayer)
    }

    func acquire(for playerLayer: AVPlayerLayer) {
        if self.playerLayer === playerLayer {
            referenceCount += 1
        }
        else {
            controller = AVPictureInPictureController(playerLayer: playerLayer)
            controller?.delegate = self
            referenceCount = 1
        }
    }

    func relinquish(for playerLayer: AVPlayerLayer) {
        guard self.playerLayer === playerLayer else { return }
        referenceCount -= 1
        if referenceCount == 0 {
            controller = nil
            DispatchQueue.main.async {
                self.clean()
            }
        }
    }

    func acquire(with release: @escaping () -> Void) {
        self.release = release
        acquire()
        stop()
    }

    func clean() {
        release?()
        release = nil
    }
}

extension PictureInPicture {
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
        acquire()
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
        relinquish()
        delegate?.pictureInPictureDidStop(self)
    }
}

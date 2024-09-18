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

    @objc private dynamic let controller: AVPictureInPictureController
    var videoViews: Set<VideoLayerView> = []

    weak var delegate: PictureInPictureDelegate?

    override init() {
        controller = AVPictureInPictureController(contentSource: .init(playerLayer: .init()))
        super.init()
        controller.delegate = self
        configureIsPossiblePublisher()
    }

    func start() {
        controller.startPictureInPicture()
    }

    func stop() {
        controller.stopPictureInPicture()
    }

    func toggle() {
        if isActive {
            stop()
        }
        else {
            start()
        }
    }

    func acquire(for view: VideoLayerView) {
        print("--> acq(\(Unmanaged.passRetained(view).toOpaque()))")
        videoViews.insert(view)
        controller.contentSource = .init(playerLayer: view.playerLayer)
    }

    func relinquish(for view: VideoLayerView) {
        videoViews.remove(view)
        print("--> rel(\(Unmanaged.passRetained(view).toOpaque()))")
        if !isActive && controller.contentSource?.playerLayer === view.playerLayer {
            print("--> kil(\(Unmanaged.passRetained(view).toOpaque()))")
            controller.contentSource = nil
            if let availableView = Array(videoViews).last {
                print("--> ac2(\(Unmanaged.passRetained(availableView).toOpaque()))")
                controller.contentSource = .init(playerLayer: availableView.playerLayer)
            }
        }
    }

    func onAppear(with player: AVPlayer, supportsPictureInPicture: Bool) {
        if !supportsPictureInPicture {
            detach(with: player)
        }
        else {
            stop()
        }
    }

    /// Avoid unnecessary pauses when transitioning via Picture in Picture to a view which does not support
    /// it.
    ///
    /// See https://github.com/SRGSSR/pillarbox-apple/issues/612 for more information.
    func detach(with player: AVPlayer) {}

    private func configureIsPossiblePublisher() {
        publisher(for: \.controller)
            .map { controller in
                controller.publisher(for: \.isPictureInPicturePossible).eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$isPossible)
    }
}

extension CustomPictureInPicture: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = true
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
        if let delegate {
            delegate.pictureInPictureRestoreUserInterfaceForStop(with: completionHandler)
        }
        else {
            completionHandler(true)
        }
    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = false
        delegate?.pictureInPictureWillStop()
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        delegate?.pictureInPictureDidStop()
    }
}

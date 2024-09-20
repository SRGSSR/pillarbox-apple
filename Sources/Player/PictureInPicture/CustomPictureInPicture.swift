//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import OrderedCollections

/// Manages Picture in Picture for `VideoView` instances.
final class CustomPictureInPicture: NSObject {
    @Published private(set) var isPossible = false
    @Published private(set) var isActive = false

    let controller = AVPictureInPictureController(playerLayer: .init())
    var videoViews: OrderedSet<HostView> = []

    weak var delegate: PictureInPictureDelegate?

    private var lastLayerView: VideoLayerView?

    override init() {
        super.init()
        controller?.delegate = self
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

    func acquire(for view: HostView, player: Player) -> VideoLayerView {
        videoViews.append(view)
        if let lastLayerView, lastLayerView.player == player.queuePlayer {
            return lastLayerView
        }
        else {
            let layerView = VideoLayerView()
            controller?.contentSource = layerView.contentSource
            return layerView
        }
    }

    func relinquish(for view: HostView) {
        videoViews.remove(view)
        if !isActive && controller?.contentSource == view.contentSource {
            if let availableView = videoViews.last {
                controller?.contentSource = availableView.contentSource
            }
            else {
                controller?.contentSource = nil
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
    func detach(with player: AVPlayer) {
        guard lastLayerView?.player === player else { return }
        lastLayerView?.player = nil
    }

    private func configureIsPossiblePublisher() {
        controller?.publisher(for: \.isPictureInPicturePossible)
            .receiveOnMainThread()
            .assign(to: &$isPossible)
    }
}

extension CustomPictureInPicture: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = true
        lastLayerView = videoViews.first(where: { $0.contentSource == pictureInPictureController.contentSource })?.layerView
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
        lastLayerView = nil
        delegate?.pictureInPictureWillStop()
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        delegate?.pictureInPictureDidStop()
    }
}

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

    private let controller = AVPictureInPictureController(playerLayer: .init())
    private var hostViews: OrderedSet<PictureInPictureHostView> = []

    weak var delegate: PictureInPictureDelegate?

    private var videoLayerView: VideoLayerView?

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

    func makeHostView(for player: Player) -> PictureInPictureHostView {
        let hostView = PictureInPictureHostView()
        hostViews.append(hostView)
        hostView.addVideoLayerView(makeVideoLayerView(for: player))
        return hostView
    }

    private func makeVideoLayerView(for player: Player) -> VideoLayerView {
        if let videoLayerView {
            if videoLayerView.player == player.queuePlayer {
                if let hostView = videoLayerView.superview as? PictureInPictureHostView {
                    hostView.addVideoLayerView(videoLayerView.duplicate())
                }
                return videoLayerView
            }
            else {
                return VideoLayerView()
            }
        }
        else {
            let layerView = VideoLayerView()
            controller?.contentSource = layerView.contentSource
            return layerView
        }
    }

    func dismantleHostView(_ hostView: PictureInPictureHostView) {
        hostViews.remove(hostView)
        if !isActive && controller?.contentSource == hostView.contentSource {
            if let lastHostView = hostViews.last {
                controller?.contentSource = lastHostView.contentSource
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
        guard videoLayerView?.player === player else { return }
        videoLayerView?.player = nil
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
        videoLayerView = hostViews.first { $0.contentSource == pictureInPictureController.contentSource }?.videoLayerView
        if let player = pictureInPictureController.parentPlayer {
            delegate?.pictureInPictureWillStart(for: player)
        }
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if let player = pictureInPictureController.parentPlayer {
            delegate?.pictureInPictureDidStart(for: player)
        }
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        if let player = pictureInPictureController.parentPlayer {
            delegate?.pictureInPictureControllerFailedToStart(for: player, with: error)
        }
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        if let delegate, let player = pictureInPictureController.parentPlayer {
            delegate.pictureInPictureRestoreUserInterfaceForStop(for: player, with: completionHandler)
        }
        else {
            completionHandler(true)
        }
    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = false
        videoLayerView = nil
        if let player = pictureInPictureController.parentPlayer {
            delegate?.pictureInPictureWillStop(for: player)
        }
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if let player = pictureInPictureController.parentPlayer {
            delegate?.pictureInPictureDidStop(for: player)
        }

        // Ensure proper resource cleanup if PiP is closed from the overlay without matching video view visible.
        if hostViews.isEmpty {
            controller?.contentSource = nil
        }
        // Wire the PiP controller to a valid source if the restored state is not bound to the player involved in
        // the restoration.
        else if !hostViews.contains(where: { $0.contentSource == controller?.contentSource }) {
            controller?.contentSource = hostViews.last?.contentSource
        }
    }
}

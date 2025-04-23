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
#if os(ios)
        controller?.canStartPictureInPictureAutomaticallyFromInline = true
#endif
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
                controller?.contentSource = .empty
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

        // Ensure proper resource cleanup if PiP is closed from the overlay without matching video view visible.
        if hostViews.isEmpty {
            controller?.contentSource = .empty
        }
        // Wire the PiP controller to a valid source if the restored state is not bound to the player involved in
        // the restoration.
        if !hostViews.contains(where: { $0.contentSource == controller?.contentSource }) {
            controller?.contentSource = hostViews.last?.contentSource
        }

        videoLayerView = nil
    }
}

private extension AVPictureInPictureController.ContentSource {
    // Setting the content source to `nil` sometimes lead to some AVFoundation-related resources not being correctly
    // released. This is likely an AVKit issue which can be mitigated with an empty content source.
    static let empty = AVPictureInPictureController.ContentSource(playerLayer: .init())
}

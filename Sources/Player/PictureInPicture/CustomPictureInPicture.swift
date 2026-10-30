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
    private var hostViews: OrderedSet<VideoHostView> = []

    weak var delegate: PictureInPictureDelegate?

    private var videoLayerView: VideoLayerView?

    override init() {
        super.init()
        controller?.delegate = self
#if os(iOS)
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

    func makeHostView(for player: Player, supportsPictureInPicture: Bool) -> VideoHostView {
        let hostView = VideoHostView()
        if supportsPictureInPicture {
            hostViews.append(hostView)
            hostView.addVideoLayerView(makeVideoLayerView(for: player))
        }
        else {
            hostView.addVideoLayerView(VideoLayerView())
        }
        return hostView
    }

    func updateHostView(_ hostView: VideoHostView, supportsPictureInPicture: Bool) {
        if supportsPictureInPicture {
            guard hostViews.append(hostView).inserted else { return }
            if videoLayerView == nil, let contentSource = hostView.contentSource {
                controller?.contentSource = contentSource
            }
        }
        else {
            guard hostViews.remove(hostView) != nil else { return }
            if !isActive && controller?.contentSource == hostView.contentSource {
                controller?.contentSource = hostViews.last?.contentSource ?? .empty
            }
        }
    }

    private func makeVideoLayerView(for player: Player) -> VideoLayerView {
        if let videoLayerView {
            if videoLayerView.player == player.queuePlayer {
                if let hostView = videoLayerView.superview as? VideoHostView {
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

    func dismantleHostView(_ hostView: VideoHostView) {
        guard hostViews.remove(hostView) != nil else { return }
        if !isActive && controller?.contentSource == hostView.contentSource {
            controller?.contentSource?.playerLayer?.player = nil
            controller?.contentSource = hostViews.last?.contentSource ?? .empty
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

    /// Avoids unnecessary pauses when transitioning via Picture in Picture to a view which does not support
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
            completionHandler(false)
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
            controller?.contentSource = hostViews.last?.contentSource ?? .empty
        }

        videoLayerView = nil
    }
}

private extension AVPictureInPictureController.ContentSource {
    // Setting the content source to `nil` sometimes lead to some AVFoundation-related resources not being correctly
    // released. This is likely an AVKit issue which can be mitigated with an empty content source.
    static let empty = AVPictureInPictureController.ContentSource(playerLayer: .init())
}

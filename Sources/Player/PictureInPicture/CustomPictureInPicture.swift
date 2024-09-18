//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine

class Ref {
    var count: Int
    let view: VideoLayerView

    init(count: Int, view: VideoLayerView) {
        self.count = count
        self.view = view
    }
}

/// Manages Picture in Picture for `VideoView` instances.
final class CustomPictureInPicture: NSObject {
    @Published private(set) var isPossible = false
    @Published private(set) var isActive = false

    @objc private dynamic let controller: AVPictureInPictureController

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
        controller.contentSource = .init(playerLayer: view.playerLayer)
    }

    func relinquish(for view: VideoLayerView) {

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
        //refs.filter { $0.view.player === player }.forEach { $0.view.player = nil }
    }

    private func configureIsPossiblePublisher() {
//        publisher(for: \.controller)
//            .map { controller in
//                guard let controller else { return Just(false).eraseToAnyPublisher() }
//                return controller.publisher(for: \.isPictureInPicturePossible).eraseToAnyPublisher()
//            }
//            .switchToLatest()
//            .receiveOnMainThread()
//            .assign(to: &$isPossible)
    }
}

extension CustomPictureInPicture: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = true
//        if let ref = refs.first(where: { $0.view.playerLayer === pictureInPictureController.playerLayer }) {
//            acquire(for: ref.view)
//        }
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
//        if let ref = refs.first(where: { $0.view.playerLayer === pictureInPictureController.playerLayer }) {
//            relinquish(for: ref.view)
//        }
        delegate?.pictureInPictureDidStop()
    }
}

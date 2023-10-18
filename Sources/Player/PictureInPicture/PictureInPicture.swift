//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine

// TODO: Must relinquish the controller when PiP is not needed anymore

public final class PictureInPicture: NSObject, ObservableObject {
    public static var shared = PictureInPicture()

    @Published private var controller: AVPictureInPictureController?

    @Published public private(set) var isPictureInPicturePossible = false
    @Published public private(set) var isPictureInPictureActive = false

    private override init() {
        super.init()

        publisher(for: \.isPictureInPicturePossible)
            .receiveOnMainThread()
            .assign(to: &$isPictureInPicturePossible)
        publisher(for: \.isPictureInPictureActive)
            .receiveOnMainThread()
            .assign(to: &$isPictureInPictureActive)
    }

    private func publisher(for keyPath: KeyPath<AVPictureInPictureController, Bool>) -> AnyPublisher<Bool, Never> {
        $controller
            .map { controller -> AnyPublisher<Bool, Never> in
                guard let controller else { return Just(false).eraseToAnyPublisher() }
                return controller.publisher(for: keyPath)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    public func start() {
        controller?.startPictureInPicture()
    }

    public func stop() {
        controller?.stopPictureInPicture()
    }

    public func toggle() {
        if isPictureInPictureActive {
            stop()
        }
        else {
            start()
        }
    }

    func assign(playerLayer: AVPlayerLayer) {
        guard controller?.playerLayer != playerLayer else { return }
        controller = AVPictureInPictureController(playerLayer: playerLayer)
        controller?.delegate = self
    }
}

extension PictureInPicture: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {

    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {

    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {

    }
}

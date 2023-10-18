//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import SwiftUI

// TODO: Must relinquish the controller / layer when PiP is not needed anymore

public final class PictureInPicture: NSObject, ObservableObject {
    public static var shared = PictureInPicture()

    @objc dynamic private var controller: AVPictureInPictureController?

    @Published public private(set) var isPictureInPicturePossible = false
    @Published public private(set) var isPictureInPictureActive = false

    fileprivate var onWillStartAction: (() -> Void)?
    fileprivate var onDidStartAction: (() -> Void)?
    fileprivate var onRestorationAction: ((@escaping (Bool) -> Void) -> Void)?
    fileprivate var onWillStopAction: (() -> Void)?
    fileprivate var onDidStopAction: (() -> Void)?

    private override init() {
        super.init()

        propertyPublisher(for: \.isPictureInPicturePossible)
            .receiveOnMainThread()
            .assign(to: &$isPictureInPicturePossible)
        propertyPublisher(for: \.isPictureInPictureActive)
            .receiveOnMainThread()
            .assign(to: &$isPictureInPictureActive)
    }

    private func propertyPublisher(for keyPath: KeyPath<AVPictureInPictureController, Bool>) -> AnyPublisher<Bool, Never> {
        publisher(for: \.controller)
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

    func assign(playerLayer: AVPlayerLayer) {
        guard controller?.playerLayer != playerLayer else { return }
        // TODO: Should likely wait until the layer is readyForDisplay
        DispatchQueue.main.async {
            self.controller = AVPictureInPictureController(playerLayer: playerLayer)
            self.controller?.delegate = self
        }
    }

    func unassign() {

    }
}

extension PictureInPicture: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        onWillStartAction?()
    }

    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        onDidStartAction?()
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        if let onRestorationAction {
            onRestorationAction(completionHandler)
        }
        else {
            completionHandler(true)
        }
    }

    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        onWillStopAction?()
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        onDidStopAction?()
    }
}

public extension View {
    func onPictureInPictureStart(perform action: @escaping () -> Void) -> some View {
        PictureInPicture.shared.onDidStartAction = action
        return self
    }

    func onPictureInPictureRestoration(perform action: @escaping (@escaping (Bool) -> Void) -> Void) -> some View {
        PictureInPicture.shared.onRestorationAction = action
        return self
    }
}

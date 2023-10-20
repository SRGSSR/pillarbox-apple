//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import SwiftUI

public protocol PictureInPictureDelegate: AnyObject {
    func willStartPictureInPicture()
    func didStartPictureInPicture()
    func restoreUserInterfaceForPictureInPictureStop(with completionHandler: @escaping (Bool) -> Void)
    func willStopPictureInPicture()
    func didStopPictureInPicture()
}

public final class PictureInPicture: NSObject, ObservableObject {
    public static var shared = PictureInPicture()

    @objc dynamic private var controller: AVPictureInPictureController?

    @Published public private(set) var isPossible = false
    @Published public private(set) var isActive = false

    fileprivate var onWillStartAction: (() -> Void)?
    fileprivate var onDidStartAction: (() -> Void)?
    fileprivate var onRestorationAction: ((@escaping (Bool) -> Void) -> Void)?
    fileprivate var onWillStopAction: (() -> Void)?
    fileprivate var onDidStopAction: (() -> Void)?

    public weak var delegate: PictureInPictureDelegate?

    private override init() {
        super.init()

        propertyPublisher(for: \.isPictureInPicturePossible)
            .receiveOnMainThread()
            .assign(to: &$isPossible)
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
        guard controller == nil, controller?.playerLayer != playerLayer else { return }
        // TODO: Should likely wait until the layer is readyForDisplay
        controller = AVPictureInPictureController(playerLayer: playerLayer)
        controller?.delegate = self
    }

    var playerLayer: AVPlayerLayer? {
        controller?.playerLayer
    }

    func unassign() {
        controller = nil
        isActive = false
    }
}

extension PictureInPicture: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isActive = true

        if let onWillStartAction {
            onWillStartAction()
        }
        else {
            delegate?.willStartPictureInPicture()
        }
    }

    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if let onDidStartAction {
            onDidStartAction()
        }
        else {
            delegate?.didStartPictureInPicture()
        }
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        let completion = { result in
            completionHandler(result)
            self.isActive = false
        }
        if let onRestorationAction {
            onRestorationAction(completion)
        }
        else if let delegate {
            delegate.restoreUserInterfaceForPictureInPictureStop(with: completion)
        }
        else {
            completion(true)
        }
    }

    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        onWillStopAction?()
        delegate?.willStopPictureInPicture()
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        onDidStopAction?()
        delegate?.didStopPictureInPicture()
        // TODO: Cleanup if closed from PiP overlay, but not possible here since stop() must not remove controller entirely
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

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Dispatch

/// Manages Picture in Picture.
public final class PictureInPicture {
    /// The shared instance managing Picture in Picture.
    public static let shared = PictureInPicture()

    let custom = CustomPictureInPicture()
    let system = SystemPictureInPicture()

    /// The Picture in Picture delegate.
    ///
    /// In-app Picture in Picture support requires your application to setup a delegate so that a playback view
    /// supporting Picture in Picture can be dismissed and restored at a later time, letting users navigate your app
    /// while playback continues in the Picture in Picture overlay.
    public weak var delegate: PictureInPictureDelegate?

    // Weak so that not retained if not explicitly acquired.
    weak var persistable: PictureInPicturePersistable?

    // Strong to retain when acquired.
    private(set) var persisted: PictureInPicturePersistable?

    private var isClosed = false

    private init() {
        custom.delegate = self
        system.delegate = self
    }

    /// Attempts to start Picture in Picture if possible.
    ///
    /// Only `VideoView` is currently supported. The method does nothing if no video view is currently available for
    /// Picture in Picture.
    ///
    /// > Important: This method must only be started in response to some form of user interaction.
    public func startIfPossible() {
        custom.start()
    }

    /// Stop Picture if Picture if running.
    ///
    /// The ``PictureInPictureDelegate/pictureInPictureRestoreUserInterfaceForStop(with:)`` method is called.
    public func stop() {
        custom.stop()
        system.stop()
    }

    /// Close Picture in Picture.
    ///
    /// The ``PictureInPictureDelegate/pictureInPictureRestoreUserInterfaceForStop(with:)`` method is not called.
    public func close() {
        isClosed = true
        stop()
    }
}

extension PictureInPicture: PictureInPictureDelegate {
    // swiftlint:disable:next missing_docs
    public func pictureInPictureWillStart() {
        delegate?.pictureInPictureWillStart()

        persisted = persistable
        persisted?.pictureInPictureWillStart()
    }

    // swiftlint:disable:next missing_docs
    public func pictureInPictureDidStart() {
        delegate?.pictureInPictureDidStart()
        persisted?.pictureInPictureDidStart()
    }

    // swiftlint:disable:next missing_docs
    public func pictureInPictureControllerFailedToStart(with error: Error) {
        delegate?.pictureInPictureControllerFailedToStart(with: error)
    }

    // swiftlint:disable:next missing_docs
    public func pictureInPictureRestoreUserInterfaceForStop(with completion: @escaping (Bool) -> Void) {
        guard !isClosed else {
            completion(true)
            return
        }
        if let delegate {
            delegate.pictureInPictureRestoreUserInterfaceForStop { finished in
                // The Picture in Picture overlay restoration animation should always occur slightly after the playback
                // user interface restoration animation starts, otherwise the restoration animation will be dropped (likely
                // because otherwise the video frame into which the PiP overlay should return cannot be determined).
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    completion(finished)
                }
            }
        }
        else {
            completion(true)
        }
    }

    // swiftlint:disable:next missing_docs
    public func pictureInPictureWillStop() {
        delegate?.pictureInPictureWillStop()
        persisted?.pictureInPictureWillStop()
    }

    // swiftlint:disable:next missing_docs
    public func pictureInPictureDidStop() {
        delegate?.pictureInPictureDidStop()
        persisted?.pictureInPictureDidStop()
        isClosed = false
        persisted = nil
    }
}

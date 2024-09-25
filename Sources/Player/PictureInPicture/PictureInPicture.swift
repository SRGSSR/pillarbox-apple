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
}

extension PictureInPicture: PictureInPictureDelegate {
    public func pictureInPictureWillStart(for player: Player) {
        delegate?.pictureInPictureWillStart(for: player)

        persisted = persistable
        persisted?.pictureInPictureWillStart(for: player)
    }

    public func pictureInPictureDidStart(for player: Player) {
        delegate?.pictureInPictureDidStart(for: player)
        persisted?.pictureInPictureDidStart(for: player)
    }

    public func pictureInPictureControllerFailedToStart(for player: Player, with error: Error) {
        delegate?.pictureInPictureControllerFailedToStart(for: player, with: error)
    }

    public func pictureInPictureRestoreUserInterfaceForStop(for player: Player, with completion: @escaping (Bool) -> Void) {
        if let delegate {
            delegate.pictureInPictureRestoreUserInterfaceForStop(for: player) { finished in
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

    public func pictureInPictureWillStop(for player: Player) {
        delegate?.pictureInPictureWillStop(for: player)
        persisted?.pictureInPictureWillStop(for: player)
    }

    public func pictureInPictureDidStop(for player: Player) {
        delegate?.pictureInPictureDidStop(for: player)
        persisted?.pictureInPictureDidStop(for: player)
        persisted = nil
    }
}

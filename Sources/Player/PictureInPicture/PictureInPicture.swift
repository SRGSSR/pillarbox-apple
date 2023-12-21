//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

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

    private init() {
        custom.delegate = self
        system.delegate = self
    }

    func stop() {
        custom.stop()
        // No stop here for system Picture in Picture see `PictureInPictureSupportingSystemVideoView` and
        // `PlayerViewController`.
    }
}

extension PictureInPicture: PictureInPictureDelegate {
    public func pictureInPictureWillStart() {
        delegate?.pictureInPictureWillStart()
        persistable?.acquire()
        persistable?.pictureInPictureWillStart()
    }

    public func pictureInPictureDidStart() {
        delegate?.pictureInPictureDidStart()
        persistable?.pictureInPictureDidStart()
    }

    public func pictureInPictureControllerFailedToStart(with error: Error) {
        delegate?.pictureInPictureControllerFailedToStart(with: error)
    }

    public func pictureInPictureRestoreUserInterfaceForStop(with completion: @escaping (Bool) -> Void) {
        delegate?.pictureInPictureRestoreUserInterfaceForStop(with: completion)
    }

    public func pictureInPictureWillStop() {
        delegate?.pictureInPictureWillStop()
        persistable?.pictureInPictureWillStop()
    }

    public func pictureInPictureDidStop() {
        delegate?.pictureInPictureDidStop()
        persistable?.pictureInPictureDidStop()
        persistable?.relinquish()
    }
}

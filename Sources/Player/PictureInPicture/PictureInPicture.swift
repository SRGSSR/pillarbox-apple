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
    /// In-app Picture in Picture support requires your application to setup a delegate so a playback view supporting
    /// Picture in Picture can be dismissed and restored at a later time, letting users navigate your app while
    /// playback continues in the Picture in Picture overlay.
    public weak var delegate: PictureInPictureDelegate?

    weak var persistable: PictureInPicturePersistable?

    private init() {
        custom.delegate = self
        system.delegate = self
    }

    func stop() {
        custom.stop()
        // For the system Picture in Picture see `PictureInPictureSupportingSystemVideoView` and `PlayerViewController`.
    }
}

extension PictureInPicture: PictureInPictureDelegate {
    public func pictureInPictureWillStart() {
        delegate?.pictureInPictureWillStart()
        persistable?.acquire()
    }

    public func pictureInPictureDidStart() {
        delegate?.pictureInPictureDidStart()
    }

    public func pictureInPictureControllerFailedToStart(with error: Error) {
        delegate?.pictureInPictureControllerFailedToStart(with: error)
    }

    public func pictureInPictureRestoreUserInterfaceForStop(with completion: @escaping (Bool) -> Void) {
        delegate?.pictureInPictureRestoreUserInterfaceForStop(with: completion)
    }

    public func pictureInPictureWillStop() {
        delegate?.pictureInPictureWillStop()
    }

    public func pictureInPictureDidStop() {
        delegate?.pictureInPictureDidStop()
        persistable?.relinquish()
    }
}

public extension View {
    /// Associates a persistable object with Picture in Picture.
    ///
    /// - Parameter persistable: The persistable object to associate.
    ///
    /// Apply this modifier where in-app Picture in Picture is desired. This ensures that resources required during
    /// playback in Picture in Picture are properly persisted. Use `PictureInPicturePersistable.persisted` to retrieve
    /// the persisted instance during view restoration.
    func persistDuringPictureInPicture(_ persistable: PictureInPicturePersistable) -> some View {
        onAppear {
            PictureInPicture.shared.stop()
            PictureInPicture.shared.persistable = persistable
        }
    }
}

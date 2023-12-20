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

    weak var supporting: PictureInPictureSupporting?

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
        supporting?.acquire()
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
        supporting?.relinquish()
    }
}

public extension View {
    func supportsInAppPictureInPicture(_ supporting: PictureInPictureSupporting) -> some View {
        onAppear {
            print("--> supporting appears")
            PictureInPicture.shared.stop()
            PictureInPicture.shared.supporting = supporting
        }
    }
}

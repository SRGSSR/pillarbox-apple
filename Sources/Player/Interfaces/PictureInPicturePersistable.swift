//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A protocol to automatically mark an object as persistable during Picture in Picture playback.
///
/// The persisted object, if any, can be retrieved from the `persisted` property. Your persisted object can also be
/// notified about the Picture in Picture lifecycle, e.g to perform some bookkeeping work or to pause / resume
/// processes.
public protocol PictureInPicturePersistable: AnyObject {
    /// Called when Picture in Picture is about to start.
    func pictureInPictureWillStart()

    /// Called when Picture in Picture has started.
    func pictureInPictureDidStart()

    /// Called when Picture in Picture is about to stop.
    func pictureInPictureWillStop()

    /// Called when Picture in Picture has stopped.
    func pictureInPictureDidStop()
}

extension PictureInPicturePersistable {
    /// The currently persisted instance, if any.
    public static var persisted: Self? {
        PictureInPicture.shared.persisted as? Self
    }
}

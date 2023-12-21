//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private var kPersisted: AnyObject?

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

public extension PictureInPicturePersistable {
    /// Default implementation. Does nothing.
    func pictureInPictureWillStart() {}

    /// Default implementation. Does nothing.
    func pictureInPictureDidStart() {}

    /// Default implementation. Does nothing.
    func pictureInPictureWillStop() {}

    /// Default implementation. Does nothing.
    func pictureInPictureDidStop() {}
}

extension PictureInPicturePersistable {
    /// The currently persisted instance, if any.
    public static var persisted: Self? {
        kPersisted as? Self
    }

    func acquire() {
        kPersisted = self
    }

    func relinquish() {
        kPersisted = nil
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol to for objects persisted during Picture in Picture playback.
///
/// The persisted object, if any, can be retrieved from the `persisted` property. The persisted object can also be
/// notified about the Picture in Picture lifecycle, e.g to perform some bookkeeping work or to pause / resume
/// processes.
public protocol PictureInPicturePersistable: AnyObject {
    /// Called when Picture in Picture is about to start.
    func pictureInPictureWillStart()

    /// Called when Picture in Picture has started.
    func pictureInPictureDidStart()

    /// Called when Picture in Picture is about to stop.
    func pictureInPictureWillStop(closed: Bool)

    /// Called when Picture in Picture has stopped.
    func pictureInPictureDidStop(closed: Bool)
}

public extension PictureInPicturePersistable {
    /// The currently persisted instance, if any.
    static var persisted: Self? {
        PictureInPicture.shared.persisted as? Self
    }

    /// Default implementation. Does nothing.
    func pictureInPictureWillStart() {}

    /// Default implementation. Does nothing.
    func pictureInPictureDidStart() {}

    /// Default implementation. Does nothing.
    func pictureInPictureWillStop(closed: Bool) {}

    /// Default implementation. Does nothing.
    func pictureInPictureDidStop(closed: Bool) {}
}

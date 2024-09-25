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
    ///
    /// - Parameter player: The player associated to the Picture in Picture.
    func pictureInPictureWillStart(for player: Player)

    /// Called when Picture in Picture has started.
    ///
    /// - Parameter player: The player associated to the Picture in Picture.
    func pictureInPictureDidStart(for player: Player)

    /// Called when Picture in Picture is about to stop.
    ///
    /// - Parameter player: The player associated to the Picture in Picture.
    func pictureInPictureWillStop(for player: Player)

    /// Called when Picture in Picture has stopped.
    ///
    /// - Parameter player: The player associated to the Picture in Picture.
    func pictureInPictureDidStop(for player: Player)
}

public extension PictureInPicturePersistable {
    /// The currently persisted instance, if any.
    static var persisted: Self? {
        PictureInPicture.shared.persisted as? Self
    }

    /// Default implementation. Does nothing.
    func pictureInPictureWillStart(for player: Player) {}

    /// Default implementation. Does nothing.
    func pictureInPictureDidStart(for player: Player) {}

    /// Default implementation. Does nothing.
    func pictureInPictureWillStop(for player: Player) {}

    /// Default implementation. Does nothing.
    func pictureInPictureDidStop(for player: Player) {}
}

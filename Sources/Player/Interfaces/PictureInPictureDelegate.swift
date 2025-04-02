//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A protocol to respond to Picture in Picture life cycle events.
///
/// Applications which require in-app Picture in Picture support must setup a delegate and rely on the Picture in
/// Picture life cycle to dismiss and restore views as required.
public protocol PictureInPictureDelegate: AnyObject {
    /// Called when Picture in Picture is about to start.
    ///
    /// Use this method to save which view was presented before dismissing it. Use the saved view for later restoration.
    func pictureInPictureWillStart()

    /// Called when Picture in Picture has started.
    func pictureInPictureDidStart()

    /// Called when Picture in Picture failed to start.
    func pictureInPictureControllerFailedToStart(with error: Error)

    /// Called when the user interface will be restored from Picture in Picture.
    ///
    /// Use this method to present the original view which Picture in Picture was initiated from. The completion handler
    /// must be called with `true` when the Picture in Picture overlay restoration animation must start.
    func pictureInPictureRestoreUserInterfaceForStop(with completion: @escaping (Bool) -> Void)

    /// Called when Picture in Picture is about to stop.
    func pictureInPictureWillStop(closed: Bool)

    /// Called when Picture in Picture has stopped.
    func pictureInPictureDidStop(closed: Bool)
}

protocol _PictureInPictureDelegate: AnyObject {
    func pictureInPictureWillStart()
    func pictureInPictureDidStart()
    func pictureInPictureControllerFailedToStart(with error: Error)
    func pictureInPictureRestoreUserInterfaceForStop(with completion: @escaping (Bool) -> Void)
    func pictureInPictureWillStop()
    func pictureInPictureDidStop()
}

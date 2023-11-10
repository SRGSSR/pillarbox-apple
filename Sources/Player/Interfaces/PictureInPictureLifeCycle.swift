//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A protocol describing the Picture in Picture life cycle.
///
/// Applications which require in-app Picture in Picture support must setup a delegate and rely on the Picture in
/// Picture life cycle to dismiss and restore views as required.
public protocol PictureInPictureLifeCycle: AnyObject {
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
    /// must be called at the very end of the restoration with `true` to notify the system that restoration is complete.
    func pictureInPictureRestoreUserInterfaceForStop(with completion: @escaping (Bool) -> Void)

    /// Called when Picture in Picture is about to stop.
    func pictureInPictureWillStop()

    /// Called when Picture in Picture has stopped.
    func pictureInPictureDidStop()
}

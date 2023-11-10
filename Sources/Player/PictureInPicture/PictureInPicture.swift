//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import SwiftUI

/// Manages Picture in Picture.
public final class PictureInPicture: NSObject {
    static let shared = PictureInPicture()

    /// Sets a delegate for Picture in Picture.
    ///
    /// In-app Picture in Picture support requires your application to setup a delegate so a playback view supporting
    /// Picture in Picture can be dismissed and restored at a later time, letting users navigate your app while
    /// playback continues in the Picture in Picture overlay.
    public static func setDelegate(_ delegate: PictureInPictureLifeCycle) {
        CustomPictureInPicture.setDelegate(delegate)
        SystemPictureInPicture.setDelegate(delegate)
    }

    /// Restores from in-app Picture in Picture playback.
    ///
    /// UIKit view controllers must call this method on view appearance to ensure playback can be automatically restored
    /// from Picture in Picture.
    public func restoreFromInAppPictureInPicture() {
        CustomPictureInPicture.shared.restoreFromInAppPictureInPicture()
        SystemPictureInPicture.shared.restoreFromInAppPictureInPicture()
    }

    /// Enables in-app Picture in Picture playback.
    ///
    /// UIKit view controllers must call this method on view disappearance to register a cleanup closure which will
    /// ensure resources which must be kept alive during Picture in Picture are properly cleaned up when Picture
    /// in Picture does not require them anymore.
    public func enableInAppPictureInPictureWithCleanup(perform cleanup: @escaping () -> Void) {
        CustomPictureInPicture.shared.enableInAppPictureInPictureWithCleanup(perform: cleanup)
        SystemPictureInPicture.shared.enableInAppPictureInPictureWithCleanup(perform: cleanup)
    }
}

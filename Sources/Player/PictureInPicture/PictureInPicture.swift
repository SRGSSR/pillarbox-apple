//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Manages Picture in Picture.
public final class PictureInPicture {
    enum Mode {
        case custom
        case system
    }

    /// The shared instance managing Picture in Picture.
    public static let shared = PictureInPicture()

    let custom = CustomPictureInPicture()
    let system = SystemPictureInPicture()

    var mode = Mode.custom

    /// Sets a delegate for Picture in Picture.
    ///
    /// In-app Picture in Picture support requires your application to setup a delegate so a playback view supporting
    /// Picture in Picture can be dismissed and restored at a later time, letting users navigate your app while
    /// playback continues in the Picture in Picture overlay.
    public func setDelegate(_ delegate: PictureInPictureDelegate) {
        custom.delegate = delegate
        system.delegate = delegate
    }

    func restoreFromInAppPictureInPicture() {
        switch mode {
        case .custom:
            custom.restoreFromInAppPictureInPicture()
        case .system:
            system.restoreFromInAppPictureInPicture()
        }
    }

    func enableInAppPictureInPictureWithCleanup(perform cleanup: @escaping () -> Void) {
        switch mode {
        case .custom:
            custom.enableInAppPictureInPictureWithCleanup(perform: cleanup)
        case .system:
            system.enableInAppPictureInPictureWithCleanup(perform: cleanup)
        }
    }
}

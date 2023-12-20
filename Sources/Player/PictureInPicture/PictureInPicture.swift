//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private var kShared: AnyObject?

public protocol PictureInPictureSupporting: AnyObject {}

extension PictureInPictureSupporting {
    public static var shared: Self? {
        kShared as? Self
    }

    func acquire() {
        kShared = self
    }

    func relinquish() {
        kShared = nil
    }
}

/// Manages Picture in Picture.
public final class PictureInPicture {
    /// The shared instance managing Picture in Picture.
    public static let shared = PictureInPicture()

    let custom = CustomPictureInPicture()
    let system = SystemPictureInPicture()

    /// Sets a delegate for Picture in Picture.
    ///
    /// In-app Picture in Picture support requires your application to setup a delegate so a playback view supporting
    /// Picture in Picture can be dismissed and restored at a later time, letting users navigate your app while
    /// playback continues in the Picture in Picture overlay.
    public func setDelegate(_ delegate: PictureInPictureDelegate) {
        custom.delegate = delegate
        system.delegate = delegate
    }

    func setSupporting(_ supporting: PictureInPictureSupporting?) {
        custom.supporting = supporting
        system.supporting = supporting
    }
}

public extension View {
    func supportsInAppPictureInPicture(_ supporting: PictureInPictureSupporting) -> some View {
        onAppear {
            print("--> supporting appears")
            PictureInPicture.shared.custom.stop()
            PictureInPicture.shared.setSupporting(supporting)
        }
        .onDisappear {
            PictureInPicture.shared.setSupporting(nil)
        }
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private var kPersisted: AnyObject?

/// A protocol to automatically mark a class as persistable during Picture in Picture playback.
///
/// The persisted instance, if any, can be retrieved from the `persisted` property.
public protocol PictureInPicturePersistable: AnyObject {}

extension PictureInPicturePersistable {
    /// The currently persisted instance associated with Picture in Picture, if any.
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

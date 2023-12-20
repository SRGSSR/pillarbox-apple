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

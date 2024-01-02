//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SceneKit

/// A video viewport.
public enum Viewport {
    /// Standard viewport.
    case standard

    /// Monoscopic viewport with the provided camera orientation.
    ///
    /// Use `.monoscopicDefault` for a camera pointing forward without head-tilting.
    case monoscopic(orientation: SCNQuaternion)
}

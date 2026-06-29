//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

extension Image {
    static func goBackward(withInterval interval: TimeInterval) -> Self {
        let imageName = "gobackward.\(Int(interval))"
        if UIImage(systemName: imageName) != nil {
            return Image(systemName: imageName)
        }
        else {
            return Image(systemName: "gobackward.minus")
        }
    }

    static func goForward(withInterval interval: TimeInterval) -> Self {
        let imageName = "goforward.\(Int(interval))"
        if UIImage(systemName: imageName) != nil {
            return Image(systemName: imageName)
        }
        else {
            return Image(systemName: "goforward.plus")
        }
    }
}

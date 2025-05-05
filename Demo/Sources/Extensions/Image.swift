//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

extension Image {
    static func goBackward(withInterval interval: TimeInterval) -> Self {
        if let uiImage = UIImage(systemName: "gobackward.\(Int(interval))") {
            return Image(uiImage: uiImage.withRenderingMode(.alwaysTemplate))
        }
        else {
            return Image(systemName: "gobackward.minus")
        }
    }

    static func goForward(withInterval interval: TimeInterval) -> Self {
        if let uiImage = UIImage(systemName: "goforward.\(Int(interval))") {
            return Image(uiImage: uiImage.withRenderingMode(.alwaysTemplate))
        }
        else {
            return Image(systemName: "goforward.plus")
        }
    }
}

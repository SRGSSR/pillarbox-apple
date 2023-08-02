//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension Player {
    /// The legible options available for selection.
    var legibleMediaSelectionOptions: [AVMediaSelectionOption] {
        legibleMediaSelectionGroup?.options ?? []
    }
}

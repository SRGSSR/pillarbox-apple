//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension Player {
    /// The audible options available for selection.
    var audibleMediaSelectionOptions: [AVMediaSelectionOption] {
        audibleMediaSelectionGroup?.options ?? []
    }
}

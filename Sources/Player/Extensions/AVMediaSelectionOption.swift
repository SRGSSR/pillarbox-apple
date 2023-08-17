//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVMediaSelectionOption {
    var languageCode: String? {
        locale?.language.languageCode?.identifier
    }
}

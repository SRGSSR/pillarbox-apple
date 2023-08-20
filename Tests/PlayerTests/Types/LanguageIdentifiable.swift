//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player

protocol LanguageIdentifiable {
    var languageIdentifier: String? { get }
}

extension MediaSelectionOption: LanguageIdentifiable {
    var languageIdentifier: String? {
        switch self {
        case let .on(option):
            return option.languageIdentifier
        default:
            return nil
        }
    }
}

extension AVMediaSelectionOption: LanguageIdentifiable {
    var languageIdentifier: String? {
        locale?.language.languageCode?.identifier
    }
}

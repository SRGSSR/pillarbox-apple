//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Nimble
import Player

/// A Nimble matcher that checks language identifiers.
func haveLanguageIdentifier<T>(_ identifier: String) -> Nimble.Predicate<T> where T: LanguageIdentifiable {
    let message = "have language identifier \(identifier)"
    return .define { actualExpression in
        let actualIdentifier = try actualExpression.evaluate()?.languageIdentifier
        return PredicateResult(
            bool: actualIdentifier == identifier,
            message: .expectedCustomValueTo(message, actual: actualIdentifier ?? "nil")
        )
    }
}

protocol LanguageIdentifiable {
    var languageIdentifier: String? { get }
}

extension MediaSelectionOption: LanguageIdentifiable {
    var languageIdentifier: String? {
        switch self {
        case let .enabled(option):
            return option.locale?.language.languageCode?.identifier
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

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Nimble
import Player

/// A Nimble matcher that checks media selection option language identifiers.
func haveLanguageIdentifier(_ identifier: String) -> Nimble.Predicate<MediaSelectionOption> {
    let errorMessage = "have language identifier \(identifier)"
    return .define { actualExpression in
        let actualValue = try actualExpression.evaluate()
        if case let .enabled(option) = actualValue,
           let actualIdentifier = option.locale?.language.languageCode?.identifier {
            return PredicateResult(
                bool: actualIdentifier == identifier,
                message: .expectedCustomValueTo(errorMessage, actual: actualIdentifier)
            )
        }
        else {
            return PredicateResult(
                status: .doesNotMatch,
                message: .expectedCustomValueTo(errorMessage, actual: "nil")
            )
        }
    }
}

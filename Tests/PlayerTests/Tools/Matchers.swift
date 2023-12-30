//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Nimble

/// A Nimble matcher that checks language identifiers.
func haveLanguageIdentifier<T>(_ identifier: String) -> Matcher<T> where T: LanguageIdentifiable {
    let message = "have language identifier \(identifier)"
    return .define { actualExpression in
        let actualIdentifier = try actualExpression.evaluate()?.languageIdentifier
        return MatcherResult(
            bool: actualIdentifier == identifier,
            message: .expectedCustomValueTo(message, actual: actualIdentifier ?? "nil")
        )
    }
}

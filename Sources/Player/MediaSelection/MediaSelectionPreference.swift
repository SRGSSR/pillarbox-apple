//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A preference for media selection (audible, legible).
public struct MediaSelectionPreference {
    enum Kind {
        case automatic
        case off
        // swiftlint:disable:next discouraged_optional_collection
        case on(languages: [String], characteristics: [AVMediaCharacteristic]?)
    }

    /// Automatic selection based on system language and accessibility settings.
    public static var automatic: Self {
        .init(kind: .automatic)
    }

    /// Disabled.
    ///
    /// Options might still be forced where applicable.
    public static var off: Self {
        .init(kind: .off)
    }

    let kind: Kind

    private init(kind: Kind) {
        self.kind = kind
    }

    /// Enabled.
    ///
    /// - Parameter languages: A list of strings containing language identifiers, in order of desirability, that are
    ///   preferred for selection. Languages can be indicated via BCP 47 language identifiers or via ISO 639-2/T
    ///   language codes.
    public static func on(languages: String...) -> Self {
        .init(kind: .on(languages: languages, characteristics: nil))
    }

    /// Enabled with explicit media characteristics.
    ///
    /// - Parameters:
    ///   - languages: A list of strings containing language identifiers, in order of desirability, that are
    ///     preferred for selection. Languages can be indicated via BCP 47 language identifiers or via ISO 639-2/T
    ///     language codes.
    ///   - characteristics: A list of media characteristics, in order of desirability, that are preferred for
    ///     selection, e.g., `.describesVideoForAccessibility` to prefer audio description tracks. These replace the
    ///     characteristics derived from system accessibility settings. An empty list prefers options without specific
    ///     characteristics, e.g., the main audio track rather than its audio description variant.
    public static func on(languages: String..., characteristics: [AVMediaCharacteristic]) -> Self {
        .init(kind: .on(languages: languages, characteristics: characteristics))
    }
}

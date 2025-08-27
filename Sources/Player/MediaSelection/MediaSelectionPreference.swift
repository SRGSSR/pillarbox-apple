//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A preference for media selection (audible, legible, etc.).
public struct MediaSelectionPreference {
    enum Kind {
        case automatic
        case off
        case on(languages: [String])
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
        .init(kind: .on(languages: languages))
    }
}

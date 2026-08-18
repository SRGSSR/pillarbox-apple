//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A preference for media selection (audible, legible, etc.) associated with a download.
public struct DownloadMediaSelectionPreference: Equatable, Codable {
    enum Kind: Equatable, Codable {
        case automatic
        case on(languages: [String])
    }

    /// Automatic selection based on system language and accessibility settings.
    public static var automatic: Self {
        .init(kind: .automatic)
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

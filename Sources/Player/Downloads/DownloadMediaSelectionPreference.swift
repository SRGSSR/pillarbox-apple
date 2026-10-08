//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A preference for media selection (audible, legible) associated with a download.
public struct DownloadMediaSelectionPreference: Equatable, Codable {
    enum Kind: Equatable, Codable {
        case automatic
        case languages([String])
        case all
    }

    /// Automatic selection based on system language and accessibility settings.
    public static var automatic: Self {
        .init(kind: .automatic)
    }

    /// All available languages.
    ///
    /// Accessibility settings are applied automatically to download variants which best match user preferences.
    public static var all: Self {
        .init(kind: .all)
    }

    let kind: Kind

    private init(kind: Kind) {
        self.kind = kind
    }

    /// Explicit language list.
    ///
    /// - Parameter languages: A list of strings containing language identifiers that should be downloaded if
    ///   available. Languages can be indicated via BCP 47 language identifiers or via ISO 639-2/T language codes.
    ///
    /// Accessibility settings are applied automatically to download variants which best match user preferences.
    public static func languages(_ languages: String...) -> Self {
        .init(kind: .languages(languages))
    }
}

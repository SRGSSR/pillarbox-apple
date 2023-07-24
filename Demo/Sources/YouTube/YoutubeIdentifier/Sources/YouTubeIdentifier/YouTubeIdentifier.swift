//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A namespace for YouTube identifier extraction utilities.
public enum YouTubeIdentifier {
    /// Extracts the YouTube identifier from the given URL.
    /// - Parameter url: The URL from which to extract the YouTube identifier.
    /// The extracted YouTube identifier if found, or `nil` if no identifier could be extracted.
    /// - Returns: The extracted YouTube identifier if found, or `nil` if no identifier could be extracted.
    public static func extract(from url: URL) -> String? {
        guard
            let match = try? Regex("https://(?:.*youtube.*v=|.*youtu.*/(?:embed/)*(?:shorts/)*)([\\w-]+)").firstMatch(in: url.absoluteString),
            let identifier = match[1].substring else {
            return nil
        }
        return String(identifier)
    }
}

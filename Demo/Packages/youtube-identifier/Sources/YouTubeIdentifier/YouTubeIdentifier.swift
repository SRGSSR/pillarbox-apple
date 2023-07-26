//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A namespace for YouTube identifier extraction utilities.
public enum YouTubeIdentifier {
    /// Extracts the YouTube identifier from the given URL.
    /// 
    /// - Parameter url: The URL from which to extract the YouTube identifier. The extracted YouTube identifier if found,
    /// or `nil` if no identifier could be extracted.
    /// - Returns: The extracted YouTube identifier if found, or `nil` if no identifier could be extracted.
    public static func extract(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

        if let vItem = components.queryItems?.first(where: { $0.name == "v" }) {
            return vItem.value
        }
        else if let host = components.host?.lowercased(), host.contains("youtube.com") || host.contains("youtu.be") {
            return components.url?.lastPathComponent
        }
        else {
            return nil
        }
    }
}

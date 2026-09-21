//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Input required to play or download URL-based content.
public struct URLInput<CustomData> {
    /// The URL of the content.
    public let url: URL

    /// Metadata associated with the content, including custom data.
    ///
    /// Custom data should include any useful information to:
    ///   - Build the kind of asset to play or download (e.g. custom or encrypted asset).
    ///   - Perform tracking.
    public let metadata: AssetMetadata<CustomData>
}

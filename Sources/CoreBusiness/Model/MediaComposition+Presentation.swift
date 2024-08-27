//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension MediaComposition {
    /// Presentations.
    enum Presentation: String, Decodable {
        /// Default.
        case `default` = "DEFAULT"

        /// 360° video.
        case video360 = "VIDEO_360"
    }
}

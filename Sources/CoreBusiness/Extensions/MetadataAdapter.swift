//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

public extension MetadataAdapter where M == MediaMetadata {
    /// A metadata adapter displaying standard media metadata.
    static let standard: Self = StandardMetadata.adapter { metadata in
        .init(
            title: metadata.title,
            subtitle: metadata.subtitle,
            description: metadata.description,
            image: metadata.image
        )
    }
}

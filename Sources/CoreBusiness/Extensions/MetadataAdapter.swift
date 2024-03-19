//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

public extension MetadataAdapter where M == MediaMetadata {
    /// A metadata adapter displaying media metadata in a standard way.
    static func common(configuration: CommonMetadata.Configuration = .init()) -> Self {
        CommonMetadata.adapter(configuration: configuration) { metadata in
            .init(
                title: metadata.title,
                subtitle: metadata.subtitle,
                description: metadata.description,
                image: metadata.image
            )
        }
    }
}

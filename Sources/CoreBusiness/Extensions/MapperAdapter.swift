//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

public extension MapperAdapter where M == MediaMetadata {
    static func standard() -> Self {
        StandardMapper.adapter { metadata in
            .init(
                title: metadata.title,
                subtitle: metadata.subtitle,
                description: metadata.description,
                image: metadata.image
            )
        }
    }
}

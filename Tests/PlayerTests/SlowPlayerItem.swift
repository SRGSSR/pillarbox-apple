//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Foundation

extension PlayerItem {
    static func simple(url: URL, metadata: Asset.Metadata? = nil, delay: TimeInterval) -> Self {
        let publisher = Just(Asset.simple(url: url, metadata: metadata))
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        return .init(publisher: publisher)
    }

    static func metadataUpdate(url: URL, delay: TimeInterval) -> Self {
        let publisher = Just(Asset.simple(
            url: url,
            metadata: .init(
                title: "title1",
                subtitle: "subtitle1",
                description: "description1"
            )
        ))
        .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
        .prepend(Asset.simple(
            url: url,
            metadata: .init(
                title: "title0",
                subtitle: "subtitle0",
                description: "description0"
            )
        ))
        return .init(publisher: publisher)
    }
}

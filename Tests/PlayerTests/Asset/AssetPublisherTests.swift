//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import PillarboxCircumspect
import PillarboxStreams

final class AssetPublisherTests: TestCase {
    func testAssetLifeCycle() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        expectAtLeastEqualPublished(values: [URL(string: "pillarbox://loading.m3u8")!, Stream.onDemand.url], from: item.$asset.map(\.resource.url)) {
            item.load()
        }
    }
}

private extension Resource {
    var url: URL {
        switch self {
        case let .simple(url: url), let .custom(url: url, delegate: _), let .encrypted(url: url, delegate: _):
            url
        }
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import PillarboxCircumspect
import PillarboxStreams

final class PlayerItemAssetPublisherTests: TestCase {
    func testNoLoad() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        expectEqualPublished(
            values: [URL(string: "pillarbox://loading.m3u8")!],
            from: item.$asset.map(\.resource.url),
            during: .milliseconds(500)
        )
    }

    func testLoad() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        expectEqualPublished(
            values: [URL(string: "pillarbox://loading.m3u8")!, Stream.onDemand.url],
            from: item.$asset.map(\.resource.url),
            during: .milliseconds(500)
        ) {
            PlayerItem.load(id: item.id)
        }
    }

    func testFailure() {
        let item = PlayerItem.failed()
        expectEqualPublished(
            values: [URL(string: "pillarbox://loading.m3u8")!, URL(string: "pillarbox://failing.m3u8")!],
            from: item.$asset.map(\.resource.url),
            during: .milliseconds(500)
        ) {
            PlayerItem.load(id: item.id)
        }
    }

    func testReload() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        expectEqualPublished(
            values: [URL(string: "pillarbox://loading.m3u8")!, Stream.onDemand.url],
            from: item.$asset.map(\.resource.url),
            during: .milliseconds(500)
        ) {
            PlayerItem.load(id: item.id)
        }

        expectEqualPublishedNext(
            values: [Stream.onDemand.url],
            from: item.$asset.map(\.resource.url),
            during: .milliseconds(500)
        ) {
            PlayerItem.load(id: item.id)
        }
    }
}

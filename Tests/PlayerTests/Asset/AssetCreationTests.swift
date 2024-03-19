//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class AssetCreationTests: TestCase {
    func testSimpleAsset() {
        let asset = Asset.simple(url: Stream.onDemand.url)
        expect(asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
    }

    func testCustomAsset() {
        let delegate = ResourceLoaderDelegateMock()
        let asset = Asset.custom(url: Stream.onDemand.url, delegate: delegate)
        expect(asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
    }

    func testEncryptedAsset() {
        let delegate = ContentKeySessionDelegateMock()
        let asset = Asset.encrypted(url: Stream.onDemand.url, delegate: delegate)
        expect(asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
    }
}

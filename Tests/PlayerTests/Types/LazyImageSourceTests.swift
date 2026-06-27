//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Foundation
import Nimble
import PillarboxCircumspect

final class LazyImageSourceTests: TestCase {
    func testNone() {
        expectAtLeastEqualPublished(
            values: [.none],
            from: ImageSource.none.lazyImageSourcePublisher()
        )
    }

    func testImage() {
        let imageData = Data()
        expectAtLeastEqualPublished(
            values: [.image(imageData)],
            from: ImageSource.image(imageData).lazyImageSourcePublisher()
        )
    }

    func testNonLoadedImageForValidUrl() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastEqualPublished(
            values: [.url(standardResolution: url)],
            from: source.lazyImageSourcePublisher()
        )
    }

    func testLoadedImageForValidUrl() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastEqualPublished(
            values: [.url(standardResolution: url), .image(try Data(contentsOf: url))],
            from: source.lazyImageSourcePublisher()
        ) {
            source.fetchData()
        }
    }

    func testFailingUrl() throws {
        let url = URL(string: "https://localhost:8123/missing.jpg")!
        let source = ImageSource.url(standardResolution: url)
        expectEqualPublished(
            values: [.url(standardResolution: url)],
            from: source.lazyImageSourcePublisher(),
            during: .milliseconds(100)
        ) {
            source.fetchData()
        }
    }
}

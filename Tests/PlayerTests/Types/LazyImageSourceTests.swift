//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import UIKit

final class LazyImageSourceTests: TestCase {
    func testNone() {
        expectAtLeastEqualPublished(
            values: [.none],
            from: ImageSource.none.lazyImageSourcePublisher()
        )
    }

    func testImage() throws {
        let image = try unwrap(UIImage(systemName: "circle"))
        expectAtLeastEqualPublished(
            values: [.image(image)],
            from: ImageSource.image(image).lazyImageSourcePublisher()
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
        let image = try unwrap(UIImage(contentsOfFile: url.path()))
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastEqualPublished(
            values: [.url(standardResolution: url), .image(image)],
            from: source.lazyImageSourcePublisher()
        ) {
            source.fetchImage()
        }
    }

    func testInvalidImageFormat() throws {
        let url = try unwrap(Bundle.module.url(forResource: "invalid", withExtension: "jpg"))
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastEqualPublished(
            values: [.url(standardResolution: url), .none],
            from: source.lazyImageSourcePublisher()
        ) {
            source.fetchImage()
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
            source.fetchImage()
        }
    }
}

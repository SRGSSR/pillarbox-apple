//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import UIKit

final class ImageSourceTests: TestCase {
    func testNone() {
        expectAtLeastEqualPublished(
            values: [.none],
            from: ImageSource.none.imageSourcePublisher()
        )
    }

    func testImage() throws {
        let image = try unwrap(UIImage(systemName: "circle"))
        expectAtLeastEqualPublished(
            values: [.image(image)],
            from: ImageSource.image(image).imageSourcePublisher()
        )
    }

    func testNonLoadedImageForValidUrl() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastEqualPublished(
            values: [.url(standardResolution: url)],
            from: source.imageSourcePublisher()
        )
    }

    func testLoadedImageForValidUrl() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let image = try unwrap(UIImage(contentsOfFile: url.path()))
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastEqualPublished(
            values: [.url(standardResolution: url), .image(image)],
            from: source.imageSourcePublisher()
        )
    }

    func testInvalidImageFormat() throws {
        let url = try unwrap(Bundle.module.url(forResource: "invalid", withExtension: "jpg"))
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastEqualPublished(
            values: [.url(standardResolution: url), .none],
            from: source.imageSourcePublisher()
        )
    }

    func testFailingUrl() throws {
        let url = URL(string: "https://localhost:8123/missing.jpg")!
        let source = ImageSource.url(standardResolution: url)
        expectEqualPublished(
            values: [.url(standardResolution: url)],
            from: source.imageSourcePublisher(),
            during: .milliseconds(100)
        )
    }
}

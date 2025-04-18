//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxCircumspect
import UIKit

final class ImageSourceTests: TestCase {
    func testNone() {
        expectAtLeastEqualPublished(
            values: [.none],
            from: ImageSource.none.imageSourcePublisher()
        )
    }

    func testImage() {
        let image = UIImage(systemName: "circle")!
        expectAtLeastEqualPublished(
            values: [.image(image)],
            from: ImageSource.image(image).imageSourcePublisher()
        )
    }

    func testNonLoadedImageForValidUrl() {
        let url = Bundle.module.url(forResource: "pixel", withExtension: "jpg")!
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastSimilarPublished(
            values: [.url(standardResolution: url)],
            from: source.imageSourcePublisher()
        )
    }

    func testLoadedImageForValidUrl() {
        let url = Bundle.module.url(forResource: "pixel", withExtension: "jpg")!
        let image = UIImage(contentsOfFile: url.path())!
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastSimilarPublished(
            values: [.url(standardResolution: url), .image(image)],
            from: source.imageSourcePublisher()
        ) {
            _ = source.image
        }
    }

    func testInvalidImageFormat() {
        let url = Bundle.module.url(forResource: "invalid", withExtension: "jpg")!
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastSimilarPublished(
            values: [.url(standardResolution: url), .none],
            from: source.imageSourcePublisher()
        ) {
            _ = source.image
        }
    }

    func testFailingUrl() {
        let url = URL(string: "https://localhost:8123/missing.jpg")!
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastSimilarPublished(
            values: [.url(standardResolution: url), .none],
            from: source.imageSourcePublisher()
        ) {
            _ = source.image
        }
    }
}

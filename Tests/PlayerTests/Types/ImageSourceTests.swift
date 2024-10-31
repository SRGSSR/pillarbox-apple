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
        expectEqualPublished(
            values: [.none],
            from: ImageSource.none.imageSourcePublisher(),
            during: .milliseconds(100)
        )
    }

    func testImage() {
        let image = UIImage(systemName: "circle")!
        expectEqualPublished(
            values: [.image(image)],
            from: ImageSource.image(image).imageSourcePublisher(),
            during: .milliseconds(100)
        )
    }

    func testNonLoadedImageForValidUrl() {
        let url = Bundle.module.url(forResource: "pixel", withExtension: "jpg")!
        let source = ImageSource.url(standardResolution: url)
        expectSimilarPublished(
            values: [.url(standardResolution: url)],
            from: source.imageSourcePublisher(),
            during: .milliseconds(100)
        )
    }

    func testLoadedImageForValidUrl() {
        let url = Bundle.module.url(forResource: "pixel", withExtension: "jpg")!
        let image = UIImage(contentsOfFile: url.path())!
        let source = ImageSource.url(standardResolution: url)
        expectSimilarPublished(
            values: [.url(standardResolution: url), .image(image)],
            from: source.imageSourcePublisher(),
            during: .milliseconds(100)
        ) {
            _ = source.image
        }
    }

    func testInvalidImageFormat() {
        let url = Bundle.module.url(forResource: "invalid", withExtension: "jpg")!
        let source = ImageSource.url(standardResolution: url)
        expectSimilarPublished(
            values: [.url(standardResolution: url), .none],
            from: source.imageSourcePublisher(),
            during: .milliseconds(100)
        ) {
            _ = source.image
        }
    }

    func testFailingUrl() {
        let url = URL(string: "https://localhost:8123/missing.jpg")!
        let source = ImageSource.url(standardResolution: url)
        expectSimilarPublished(
            values: [.url(standardResolution: url), .none],
            from: source.imageSourcePublisher(),
            during: .seconds(1)
        ) {
            _ = source.image
        }
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CircumspectTests
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

    func testValidUrl() {
        let url = Bundle.module.url(forResource: "pixel", withExtension: "jpg")!
        let image = UIImage(contentsOfFile: url.path())!
        expectSimilarPublished(
            values: [.url(url), .image(image)],
            from: ImageSource.url(url).imageSourcePublisher(),
            during: .milliseconds(100)
        )
    }

    func testInvalidImageFormat() {
        let url = Bundle.module.url(forResource: "invalid", withExtension: "jpg")!
        expectSimilarPublished(
            values: [.url(url), .none],
            from: ImageSource.url(url).imageSourcePublisher(),
            during: .milliseconds(100)
        )
    }

    func testFailingUrl() {
        let url = URL(string: "https://localhost/missing.jpg")!
        expectSimilarPublished(
            values: [.url(url), .none],
            from: ImageSource.url(url).imageSourcePublisher(),
            during: .seconds(1)
        )
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Foundation
import Nimble
import PillarboxCircumspect

final class ImageSourceTests: TestCase {
    func testNone() {
        expectAtLeastEqualPublished(
            values: [.none],
            from: ImageSource.none.imageSourcePublisher()
        )
    }

    func testImage() {
        let imageData = Data()
        expectAtLeastEqualPublished(
            values: [.image(imageData)],
            from: ImageSource.image(imageData).imageSourcePublisher()
        )
    }

    func testImageForValidUrl() throws {
        let url = try unwrap(Bundle.module.url(forResource: "pixel", withExtension: "jpg"))
        let source = ImageSource.url(standardResolution: url)
        expectAtLeastEqualPublished(
            values: [.image(try Data(contentsOf: url))],
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

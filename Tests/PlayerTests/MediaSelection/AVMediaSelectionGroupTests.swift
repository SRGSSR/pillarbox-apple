//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble

final class AVMediaSelectionGroupTests: TestCase {
    func testPreferredMediaSelectionOptionsWithCharacteristics() {
        let options: [AVMediaSelectionOptionMock] = [
            .init(displayName: "Option 1 (music)", languageCode: "fr", characteristics: [.describesMusicAndSoundForAccessibility]),
            .init(displayName: "Option 2", languageCode: "fr", characteristics: []),
            .init(displayName: "Option 3 (music)", languageCode: "en", characteristics: [.describesMusicAndSoundForAccessibility]),
            .init(displayName: "Option 4", languageCode: "it", characteristics: [])
        ]

        expect(
            AVMediaSelectionGroup.preferredMediaSelectionOptions(
                from: options,
                withMediaCharacteristics: [.describesMusicAndSoundForAccessibility]
            )
            .map(\.displayName)
            .sorted()
        )
        .to(equal([
            "Option 1 (music)",
            "Option 3 (music)",
            "Option 4"
        ]))
    }

    func testPreferredMediaSelectionOptionsWithoutCharacteristics() {
        let options: [AVMediaSelectionOptionMock] = [
            .init(displayName: "Option 1 (music)", languageCode: "fr", characteristics: [.describesMusicAndSoundForAccessibility]),
            .init(displayName: "Option 2", languageCode: "fr", characteristics: []),
            .init(displayName: "Option 3 (music)", languageCode: "en", characteristics: [.describesMusicAndSoundForAccessibility]),
            .init(displayName: "Option 4", languageCode: "it", characteristics: [])
        ]

        expect(
            AVMediaSelectionGroup.preferredMediaSelectionOptions(
                from: options,
                withoutMediaCharacteristics: [.describesMusicAndSoundForAccessibility]
            )
            .map(\.displayName)
            .sorted()
        )
        .to(equal([
            "Option 2",
            "Option 3 (music)",
            "Option 4"
        ]))
    }
}

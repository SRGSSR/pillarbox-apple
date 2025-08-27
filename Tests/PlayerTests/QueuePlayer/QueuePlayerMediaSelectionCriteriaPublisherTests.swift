//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import PillarboxCircumspect

// swiftlint:disable:next type_name
final class QueuePlayerMediaSelectionCriteriaPublisherTests: TestCase {
    func testDefault() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(
            values: [[:]],
            from: player.mediaSelectionCriteriaPublisher()
        )
    }

    func testInitialValue() {
        let player = QueuePlayer()
        let criteria = AVPlayerMediaSelectionCriteria(
            preferredLanguages: ["en", "fr"],
            preferredMediaCharacteristics: [.transcribesSpokenDialogForAccessibility, .describesMusicAndSoundForAccessibility]
        )
        player.setMediaSelectionCriteria(criteria, forMediaCharacteristic: .legible)
        expectAtLeastEqualPublished(
            values: [
                [.legible: criteria]
            ],
            from: player.mediaSelectionCriteriaPublisher()
        )
    }

    func testUpdate() {
        let player = QueuePlayer()
        let criteria = AVPlayerMediaSelectionCriteria(
            preferredLanguages: ["en", "fr"],
            preferredMediaCharacteristics: [.transcribesSpokenDialogForAccessibility, .describesMusicAndSoundForAccessibility]
        )
        expectAtLeastEqualPublishedNext(
            values: [
                [.legible: criteria]
            ],
            from: player.mediaSelectionCriteriaPublisher()
        ) {
            player.setMediaSelectionCriteria(criteria, forMediaCharacteristic: .legible)
        }
    }

    func testReset() {
        let player = QueuePlayer()
        let criteria = AVPlayerMediaSelectionCriteria(
            preferredLanguages: ["en", "fr"],
            preferredMediaCharacteristics: [.transcribesSpokenDialogForAccessibility, .describesMusicAndSoundForAccessibility]
        )
        player.setMediaSelectionCriteria(criteria, forMediaCharacteristic: .legible)
        expectAtLeastEqualPublishedNext(
            values: [[:]],
            from: player.mediaSelectionCriteriaPublisher()
        ) {
            player.setMediaSelectionCriteria(nil, forMediaCharacteristic: .legible)
        }
    }
}

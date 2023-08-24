//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import MediaAccessibility
import Nimble
import Streams
import XCTest

final class MediaSelectionCriteriaTests: TestCase {
    func testCharacteristicsAndOptionsWithMediaSelectionCriteria() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionCriteria(preferredLanguages: ["fr"], for: .audible)
        expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))

        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    func testAudibleOptionWithMediaSelectionCriteria() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionCriteria(preferredLanguages: ["fr"], for: .audible)
        expect(player.selectedMediaOption(for: .audible)).toAlways(equal(.off), until: .seconds(2))
    }

    func testLegibleMediaSelectionCriteriaWithUnknownOrUnavailableLanguage() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionCriteria(preferredLanguages: ["xy", "it"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
    }

    func testLegibleMediaSelectionCriteriaWithAvailableLanguage() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionCriteria(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testLegibleMediaSelectionCriteriaOverride() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)

        player.setMediaSelectionCriteria(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testLegibleMediaSelectionCriteriaReset() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionCriteria(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelectionCriteria(preferredLanguages: [], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
    }

    func testAudibleMediaSelectionCriteriaWithUnknownOrUnavailableLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionCriteria(preferredLanguages: ["xy", "it"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    func testAudibleMediaSelectionCriteriaWithAvailableLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionCriteria(preferredLanguages: ["fr"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testAudibleMediaSelectionCriteriaOverride() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)

        player.setMediaSelectionCriteria(preferredLanguages: ["en"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    func testAudibleMediaSelectionCriteriaReset() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionCriteria(preferredLanguages: ["fr"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelectionCriteria(preferredLanguages: [], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }
}

private extension Player {
    func group(for characteristic: AVMediaCharacteristic) async throws -> AVMediaSelectionGroup? {
        guard let item = systemPlayer.currentItem else { return nil }
        return try await item.asset.loadMediaSelectionGroup(for: characteristic)
    }
}

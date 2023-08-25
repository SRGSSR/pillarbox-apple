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
    func testAudibleOptionMatchesAvailablePreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .audible)
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testLegibleOptionMatchesAvailablePreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testAudibleOptionIgnoresInvalidLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["xy"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toNever(haveLanguageIdentifier("xy"), until: .seconds(2))
    }

    func testLegibleOptionIgnoresInvalidLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["xy"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toNever(haveLanguageIdentifier("xy"), until: .seconds(2))
    }

    func testAudibleOptionIgnoresUnsupportedLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["it"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toNever(haveLanguageIdentifier("it"), until: .seconds(2))
    }

    func testLegibleOptionIgnoresUnsupportedLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["it"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toNever(haveLanguageIdentifier("it"), until: .seconds(2))
    }

    func testAudibleCriteriaOverrideSelection() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)

        player.setMediaSelection(preferredLanguages: ["en"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    func testLegibleCriteriaOverrideSelection() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)

        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testAudibleCriteriaReset() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelection(preferredLanguages: [], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    func testLegibleCriteriaReset() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelection(preferredLanguages: [], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
    }

    func testLegibleCriteriaOverridePersistedOnOption() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testLegibleCriteriaOverridePersistedAutomaticOption() {
        MediaAccessibilityDisplayType.automatic.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testLegibleCriteriaOverridePersistedOffOption() {
        MediaAccessibilityDisplayType.forcedOnly.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testAudibleCriteriaArePreservedBetweenItems() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "en").apply()

        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        player.setMediaSelection(preferredLanguages: ["fr"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testLegibleCriteriaArePreservedBetweenItems() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "en").apply()

        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testAudibleSelectionIsPreservedBetweenItems() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "en").apply()

        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testLegibleSelectionIsPreservedBetweenItems() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "en").apply()

        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }
}

//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class PreferredLanguagesForMediaSelectionTests: TestCase {
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

    func testAudibleOptionIgnoresInvalidPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["xy"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toNever(haveLanguageIdentifier("xy"), until: .seconds(2))
    }

    func testLegibleOptionIgnoresInvalidPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["xy"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toNever(haveLanguageIdentifier("xy"), until: .seconds(2))
    }

    func testAudibleOptionIgnoresUnsupportedPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["it"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toNever(haveLanguageIdentifier("it"), until: .seconds(2))
    }

    func testLegibleOptionIgnoresUnsupportedPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["it"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toNever(haveLanguageIdentifier("it"), until: .seconds(2))
    }

    func testPreferredAudibleLanguageOverrideSelection() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)

        player.setMediaSelection(preferredLanguages: ["en"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    func testPreferredLegibleLanguageOverrideSelection() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)

        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testPreferredAudibleLanguageIsPreservedBetweenItems() {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        player.setMediaSelection(preferredLanguages: ["fr"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testPreferredLegibleLanguageIsPreservedBetweenItems() {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testPreferredLegibleLanguageAcrossItems() {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithManyLegibleAndAudibleOptions.url)
        ])

        player.setMediaSelection(preferredLanguages: ["en"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.advanceToNextItem()
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.setMediaSelection(preferredLanguages: ["it"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("it"))

        player.returnToPrevious()
        expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))
    }

    func testEmptyAudibleMediaSelection() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelection(preferredLanguages: [], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    func testEmptyLegibleMediaSelection() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelection(preferredLanguages: [], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))
    }

    func testSelectLegibleOffOptionWithPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))

        player.setMediaSelection(preferredLanguages: ["en"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.select(mediaOption: .off, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
    }

    func testSelectLegibleAutomaticOptionWithPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))

        player.setMediaSelection(preferredLanguages: ["en"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.select(mediaOption: .automatic, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
    }

    func testSelectLegibleOffOptionWithEmptyLanguages() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))

        player.setMediaSelection(preferredLanguages: [], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))

        player.select(mediaOption: .off, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
    }

    func testSelectLegibleOptionWithEmptyLanguages() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))

        player.setMediaSelection(preferredLanguages: [], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))

        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())
        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    func testSelectLegibleAutomaticOptionWithEmptyLanguages() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))

        player.setMediaSelection(preferredLanguages: [], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))

        player.select(mediaOption: .automatic, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
    }

    func testAudibleMediaSelectionReset() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        player.resetMediaSelectionPreferredLanguages(for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    func testLegibleMediaSelectionReset() {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.resetMediaSelectionPreferredLanguages(for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
    }

    func testMediaSelectionUpdatePublishesPlayerUpdate() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.play()
        expect(player.time().seconds).toEventually(beGreaterThan(1))
        expectChange(from: player, timeout: .milliseconds(500)) {
            player.setMediaSelection(preferredLanguages: [], for: .legible)
        }
    }
}

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
    @MainActor
    func testAudibleOptionMatchesAvailablePreferredLanguage() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "fr"), for: .audible)
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testLegibleOptionMatchesAvailablePreferredLanguage() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "fr"), for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testAudibleOptionIgnoresInvalidPreferredLanguage() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "xy"), for: .audible)
        await expect(player.currentMediaOption(for: .audible)).toNever(haveLanguageIdentifier("xy"), until: .seconds(2))
    }

    @MainActor
    func testLegibleOptionIgnoresInvalidPreferredLanguage() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "xy"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toNever(haveLanguageIdentifier("xy"), until: .seconds(2))
    }

    @MainActor
    func testAudibleOptionIgnoresUnsupportedPreferredLanguage() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "it"), for: .audible)
        await expect(player.currentMediaOption(for: .audible)).toNever(haveLanguageIdentifier("it"), until: .seconds(2))
    }

    @MainActor
    func testLegibleOptionIgnoresUnsupportedPreferredLanguage() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "it"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toNever(haveLanguageIdentifier("it"), until: .seconds(2))
    }

    @MainActor
    func testPreferredAudibleLanguageOverrideSelection() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)

        player.setMediaSelectionPreference(.on(languages: "en"), for: .audible)
        await expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testPreferredLegibleLanguageOverrideSelection() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)

        player.setMediaSelectionPreference(.on(languages: "fr"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testPreferredAudibleLanguageIsPreservedBetweenItems() async {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        player.setMediaSelectionPreference(.on(languages: "fr"), for: .audible)
        await expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        await expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testPreferredLegibleLanguageIsPreservedBetweenItems() async {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        player.setMediaSelectionPreference(.on(languages: "fr"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testPreferredLegibleLanguageAcrossItems() async {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithManyLegibleAndAudibleOptions.url)
        ])

        player.setMediaSelectionPreference(.on(languages: "en"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.advanceToNextItem()
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.setMediaSelectionPreference(.on(languages: "it"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("it"))

        player.returnToPreviousItem()
        await expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))
    }

    @MainActor
    func testEmptyAudibleMediaSelection() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "fr"), for: .audible)
        await expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelectionPreference(.off, for: .audible)
        await expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testEmptyLegibleMediaSelection() async {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "fr"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelectionPreference(.off, for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))
    }

    @MainActor
    func testSelectLegibleOffOptionWithPreferredLanguage() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.setMediaSelectionPreference(.on(languages: "en"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.select(mediaOption: .off, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
    }

    @MainActor
    func testSelectLegibleAutomaticOptionWithPreferredLanguage() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.setMediaSelectionPreference(.on(languages: "en"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.select(mediaOption: .automatic, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
    }

    @MainActor
    func testSelectLegibleOffOptionWithEmptyLanguages() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.setMediaSelectionPreference(.off, for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))

        player.select(mediaOption: .off, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
    }

    @MainActor
    func testSelectLegibleOptionWithEmptyLanguages() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.setMediaSelectionPreference(.off, for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))

        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())
        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testSelectLegibleAutomaticOptionWithEmptyLegibleLanguages() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.setMediaSelectionPreference(.off, for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))

        player.select(mediaOption: .automatic, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
    }

    @MainActor
    func testSelectLegibleAutomaticOptionWithEmptyAudibleAndLegibleLanguages() async {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.setMediaSelectionPreference(.off, for: .audible)
        player.setMediaSelectionPreference(.off, for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))

        player.select(mediaOption: .automatic, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        await expect(player.currentMediaOption(for: .legible)).toNever(haveLanguageIdentifier("ja"), until: .seconds(1))
    }

    @MainActor
    func testAutomaticAudibleMediaSelection() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "fr"), for: .audible)
        await expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelectionPreference(.automatic, for: .audible)
        await expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testAutomaticLegibleMediaSelection() async {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionPreference(.on(languages: "fr"), for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelectionPreference(.automatic, for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
    }
}

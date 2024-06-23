//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxStreams

final class PreferredLanguagesForMediaSelectionTests: TestCase {
    @MainActor
    func testAudibleOptionMatchesAvailablePreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .audible)
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testLegibleOptionMatchesAvailablePreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testAudibleOptionIgnoresInvalidPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["xy"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toNever(haveLanguageIdentifier("xy"), until: .seconds(2))
    }

    @MainActor
    func testLegibleOptionIgnoresInvalidPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["xy"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toNever(haveLanguageIdentifier("xy"), until: .seconds(2))
    }

    @MainActor
    func testAudibleOptionIgnoresUnsupportedPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["it"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toNever(haveLanguageIdentifier("it"), until: .seconds(2))
    }

    @MainActor
    func testLegibleOptionIgnoresUnsupportedPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["it"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toNever(haveLanguageIdentifier("it"), until: .seconds(2))
    }

    @MainActor
    func testPreferredAudibleLanguageOverrideSelection() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)

        player.setMediaSelection(preferredLanguages: ["en"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testPreferredLegibleLanguageOverrideSelection() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)

        player.setMediaSelection(preferredLanguages: ["fr"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
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

    @MainActor
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

    @MainActor
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
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testSelectLegibleOffOptionWithPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))

        player.setMediaSelection(preferredLanguages: ["en"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.select(mediaOption: .off, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
    }

    @MainActor
    func testSelectLegibleAutomaticOptionWithPreferredLanguage() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))

        player.setMediaSelection(preferredLanguages: ["en"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("en"))

        player.select(mediaOption: .automatic, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
    }

    @MainActor
    func testMediaSelectionReset() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelection(preferredLanguages: ["fr"], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        player.setMediaSelection(preferredLanguages: [], for: .audible)
        expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
    }
}

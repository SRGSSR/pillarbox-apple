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

private enum MediaAccessibilityDisplayType {
    case automatic
    case forcedOnly
    case alwaysOn(languageCode: String)
}

final class MediaSelectionTests: TestCase {
    private func setupAccessibilityDisplayType(_ type: MediaAccessibilityDisplayType) {
        switch type {
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
        case .forcedOnly:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
        case let .alwaysOn(languageCode: languageCode):
            MACaptionAppearanceSetDisplayType(.user, .alwaysOn)
            MACaptionAppearanceAddSelectedLanguage(.user, languageCode as CFString)
        }
    }

    func testCharacteristicsAndOptionsWhenEmpty() {
        let player = Player()
        expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    func testCharacteristicsAndOptionsWhenAvailable() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))
        expect(player.mediaSelectionOptions(for: .audible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    func testCharacteristicsAndOptionsWhenFailed() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    func testWithoutCharacteristicsAndOptions() {
        let player = Player(item: .simple(url: Stream.onDemandWithoutOptions.url))
        expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    func testCharacteristicsAndOptionsWhenAdvancingToNextItem() {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithoutOptions.url)
        ])
        expect(player.mediaSelectionCharacteristics).toEventuallyNot(beEmpty())
        player.advanceToNextItem()
        expect(player.mediaSelectionCharacteristics).toEventually(beEmpty())
    }

    func testSingleAudibleOptionIsNeverReturned() {
        let player = Player(item: .simple(url: Stream.onDemandWithSingleAudibleOption.url))
        expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible]))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
    }

    func testLegibleOptionsMustNotContainForcedSubtitles() {
        let player = Player(item: .simple(url: Stream.onDemandWithForcedAndUnforcedLegibleOptions.url))
        expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))
        expect(player.mediaSelectionOptions(for: .legible).count).to(equal(6))
    }

    func testInitialAudibleOption() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        expect(player.currentMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    func testInitialLegibleOptionWithAlwaysOnAccessibilityDisplayType() {
        setupAccessibilityDisplayType(.alwaysOn(languageCode: "ja"))

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        expect(player.currentMediaOption(for: .legible)).to(haveLanguageIdentifier("ja"))
    }

    func testInitialLegibleOptionWithAutomaticAccessibilityDisplayType() {
        setupAccessibilityDisplayType(.automatic)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    func testInitialLegibleOptionWithForcedOnlyAccessibilityDisplayType() {
        setupAccessibilityDisplayType(.forcedOnly)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    func testInitialAudibleOptionWithoutAvailableOptions() {
        let player = Player(item: .simple(url: Stream.onDemandWithoutOptions.url))
        expect(player.selectedMediaOption(for: .audible)).toAlways(equal(.off), until: .seconds(2))
        expect(player.currentMediaOption(for: .audible)).to(equal(.off))
    }

    func testInitialLegibleOptionWithoutAvailableOptions() {
        setupAccessibilityDisplayType(.forcedOnly)

        let player = Player(item: .simple(url: Stream.onDemandWithoutOptions.url))
        expect(player.selectedMediaOption(for: .legible)).toAlways(equal(.off), until: .seconds(2))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    func testAudibleOptionUpdateWhenAdvancingToNextItem() {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithoutOptions.url)
        ])
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        player.advanceToNextItem()
        expect(player.selectedMediaOption(for: .audible)).toEventually(equal(.off))
    }

    func testLegibleOptionUpdateWhenAdvancingToNextItem() {
        setupAccessibilityDisplayType(.alwaysOn(languageCode: "fr"))

        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithoutOptions.url)
        ])
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.advanceToNextItem()
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
    }

    // When using AirPlay the receiver might offer forced subtitle selection, thus changing subtitles externally. In
    // this case the perceived selected option must be `.off`.
    @MainActor
    func testLegibleOptionStaysOffEvenIfForcedSubtitlesAreEnabledExternally() async throws {
        setupAccessibilityDisplayType(.alwaysOn(languageCode: "ja"))

        let player = Player(item: .simple(url: Stream.onDemandWithForcedAndUnforcedLegibleOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        let group = try await player.group(for: .legible)!
        let option = AVMediaSelectionGroup.mediaSelectionOptions(
            from: group.options,
            withMediaCharacteristics: [.containsOnlyForcedSubtitles]
        )
        .first { option in
            option.languageIdentifier == "ja"
        }!

        // Simulates an external change using the low-level player API directly.
        player.systemPlayer.currentItem?.select(option, in: group)

        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
    }

    func testSelectAudibleOnOption() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        expect(player.currentMediaOption(for: .audible)).to(haveLanguageIdentifier("fr"))
    }

    func testSelectAudibleAutomaticOptionDoesNothing() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .automatic, for: .audible)
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        expect(player.currentMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    func testSelectAudibleOffOptionDoesNothing() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .off, for: .audible)
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        expect(player.currentMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    func testSelectLegibleOnOption() {
        setupAccessibilityDisplayType(.forcedOnly)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        expect(player.currentMediaOption(for: .legible)).to(haveLanguageIdentifier("ja"))
    }

    func testSelectLegibleAutomaticOption() {
        setupAccessibilityDisplayType(.forcedOnly)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .automatic, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    func testSelectLegibleOffOption() {
        setupAccessibilityDisplayType(.automatic)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .off, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    func testSelectIncompatibleOptionDoesNothing() {
        setupAccessibilityDisplayType(.forcedOnly)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        let firstAudibleOption = player.mediaSelectionOptions(for: .audible).first!
        player.select(mediaOption: firstAudibleOption, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toAlways(equal(.off), until: .seconds(2))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    func testLegibleOptionSwitchFromOffToAutomatic() {
        setupAccessibilityDisplayType(.forcedOnly)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())
        player.select(mediaOption: .automatic, for: .legible)

        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    func testLegibleMediaSelectionCriteriaWithUnknownOrUnavailableLanguage() {
        setupAccessibilityDisplayType(.alwaysOn(languageCode: "ja"))

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        player.setMediaSelectionCriteria(preferredLanguages: ["xy", "it"], for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
    }

    func testLegibleMediaSelectionCriteriaWithAvailableLanguage() {
        setupAccessibilityDisplayType(.alwaysOn(languageCode: "ja"))

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
        setupAccessibilityDisplayType(.alwaysOn(languageCode: "ja"))

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

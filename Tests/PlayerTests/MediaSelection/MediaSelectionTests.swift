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

final class MediaSelectionTests: TestCase {
    @MainActor
    func testCharacteristicsAndOptionsWhenEmpty() async {
        let player = Player()
        await expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    @MainActor
    func testCharacteristicsAndOptionsWhenAvailable() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))
        expect(player.mediaSelectionOptions(for: .audible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    @MainActor
    func testCharacteristicsAndOptionsWhenFailed() async {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        await expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    @MainActor
    func testCharacteristicsAndOptionsWhenExhausted() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionCharacteristics).toEventuallyNot(beEmpty())
        player.play()
        await expect(player.mediaSelectionCharacteristics).toEventually(beEmpty())
    }

    @MainActor
    func testCharacteristicsAndOptionsWhenUnavailable() async {
        let player = Player(item: .simple(url: Stream.onDemandWithoutOptions.url))
        await expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    @MainActor
    func testCharacteristicsAndOptionsUpdateWhenAdvancingToNextItem() async {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithoutOptions.url)
        ])
        await expect(player.mediaSelectionCharacteristics).toEventuallyNot(beEmpty())
        player.advanceToNextItem()
        await expect(player.mediaSelectionCharacteristics).toEventually(beEmpty())
    }

    @MainActor
    func testSingleAudibleOptionIsNeverReturned() async {
        let player = Player(item: .simple(url: Stream.onDemandWithSingleAudibleOption.url))
        await expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible]))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
    }

    @MainActor
    func testLegibleOptionsMustNotContainForcedSubtitles() async {
        let player = Player(item: .simple(url: Stream.onDemandWithForcedAndUnforcedLegibleOptions.url))
        await expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))
        expect(player.mediaSelectionOptions(for: .legible)).to(haveCount(6))
    }

    @MainActor
    func testInitialAudibleOption() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        expect(player.currentMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testInitialLegibleOptionWithAlwaysOnAccessibilityDisplayType() async {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        expect(player.currentMediaOption(for: .legible)).to(haveLanguageIdentifier("ja"))
    }

    @MainActor
    func testInitialLegibleOptionWithAutomaticAccessibilityDisplayType() async {
        MediaAccessibilityDisplayType.automatic.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    @MainActor
    func testInitialLegibleOptionWithForcedOnlyAccessibilityDisplayType() async {
        MediaAccessibilityDisplayType.forcedOnly.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    @MainActor
    func testInitialAudibleOptionWithoutAvailableOptions() async {
        let player = Player(item: .simple(url: Stream.onDemandWithoutOptions.url))
        await expect(player.selectedMediaOption(for: .audible)).toAlways(equal(.off), until: .seconds(2))
        expect(player.currentMediaOption(for: .audible)).to(equal(.off))
    }

    @MainActor
    func testInitialLegibleOptionWithoutAvailableOptions() async {
        MediaAccessibilityDisplayType.forcedOnly.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithoutOptions.url))
        await expect(player.selectedMediaOption(for: .legible)).toAlways(equal(.off), until: .seconds(2))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    @MainActor
    func testAudibleOptionUpdateWhenAdvancingToNextItem() async {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithoutOptions.url)
        ])
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        player.advanceToNextItem()
        await expect(player.selectedMediaOption(for: .audible)).toEventually(equal(.off))
    }

    @MainActor
    func testLegibleOptionUpdateWhenAdvancingToNextItem() async {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "fr").apply()

        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithoutOptions.url)
        ])
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.advanceToNextItem()
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
    }

    // When using AirPlay the receiver might offer forced subtitle selection, thus changing subtitles externally. In
    // this case the perceived selected option must be `.off`.
    @MainActor
    func testLegibleOptionStaysOffEvenIfForcedSubtitlesAreEnabledExternally() async throws {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "ja").apply()

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

    @MainActor
    func testSelectAudibleOnOption() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        expect(player.currentMediaOption(for: .audible)).to(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testSelectAudibleAutomaticOptionDoesNothing() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .automatic, for: .audible)
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        expect(player.currentMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testSelectAudibleOffOptionDoesNothing() async {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .off, for: .audible)
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        expect(player.currentMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testSelectLegibleOnOption() async {
        MediaAccessibilityDisplayType.forcedOnly.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        expect(player.currentMediaOption(for: .legible)).to(haveLanguageIdentifier("ja"))
    }

    @MainActor
    func testSelectLegibleAutomaticOption() async {
        MediaAccessibilityDisplayType.forcedOnly.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .automatic, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    @MainActor
    func testSelectLegibleOffOption() async {
        MediaAccessibilityDisplayType.automatic.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .off, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.off))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    @MainActor
    func testAudibleSelectionIsPreservedBetweenItems() async {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "en").apply()

        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        await expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)
        await expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        await expect(player.currentMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testLegibleSelectionIsPreservedBetweenItems() async {
        MediaAccessibilityDisplayType.alwaysOn(languageCode: "en").apply()

        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithOptions.url)
        ])
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .legible)
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))

        player.advanceToNextItem()
        await expect(player.currentMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
    }

    @MainActor
    func testLegibleOptionSwitchFromOffToAutomatic() async {
        MediaAccessibilityDisplayType.forcedOnly.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())
        player.select(mediaOption: .automatic, for: .legible)

        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        expect(player.currentMediaOption(for: .legible)).to(equal(.off))
    }

    @MainActor
    func testObservabilityWhenTogglingBetweenOffAndAutomatic() async {
        MediaAccessibilityDisplayType.forcedOnly.apply()

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        expectChange(from: player) {
            player.select(mediaOption: .automatic, for: .legible)
        }
        expectChange(from: player) {
            player.select(mediaOption: .off, for: .legible)
        }
    }
}

private extension Player {
    func group(for characteristic: AVMediaCharacteristic) async throws -> AVMediaSelectionGroup? {
        guard let item = systemPlayer.currentItem else { return nil }
        return try await item.asset.loadMediaSelectionGroup(for: characteristic)
    }
}

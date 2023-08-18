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
    case disabled
    case enabled(languageCode: String)
}

final class MediaSelectionTests: TestCase {
    private static func setupLegibleSelectionTestWithAccessibilityDisplayType(_ type: MediaAccessibilityDisplayType) {
        switch type {
        case .automatic:
            MACaptionAppearanceSetDisplayType(.user, .automatic)
        case .disabled:
            MACaptionAppearanceSetDisplayType(.user, .forcedOnly)
        case let .enabled(languageCode: languageCode):
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

    func testInitiallySelectedEnabledAudibleOption() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        expect(player.activeMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    func testInitiallySelectedEnabledLegibleOption() {
        Self.setupLegibleSelectionTestWithAccessibilityDisplayType(.enabled(languageCode: "ja"))

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        expect(player.activeMediaOption(for: .legible)).to(haveLanguageIdentifier("ja"))
    }

    func testInitiallySelectedAutomaticLegibleOption() {
        Self.setupLegibleSelectionTestWithAccessibilityDisplayType(.automatic)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        expect(player.activeMediaOption(for: .legible)).to(equal(.disabled))
    }

    func testInitiallySelectedAudibleOptionWithoutOptions() {
        let player = Player(item: .simple(url: Stream.onDemandWithoutOptions.url))
        expect(player.selectedMediaOption(for: .audible)).toAlways(equal(.disabled), until: .seconds(2))
        expect(player.activeMediaOption(for: .audible)).to(equal(.disabled))
    }

    func testInitiallySelectedLegibleOptionWithoutOptions() {
        Self.setupLegibleSelectionTestWithAccessibilityDisplayType(.disabled)

        let player = Player(item: .simple(url: Stream.onDemandWithoutOptions.url))
        expect(player.selectedMediaOption(for: .legible)).toAlways(equal(.disabled), until: .seconds(2))
        expect(player.activeMediaOption(for: .legible)).to(equal(.disabled))
    }

    func testInitiallySelectedDisabledLegibleOption() {
        Self.setupLegibleSelectionTestWithAccessibilityDisplayType(.disabled)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.disabled))
        expect(player.activeMediaOption(for: .legible)).to(equal(.disabled))
    }

    func testSelectedAudibleOptionWhenAdvancingToNextItem() {
        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithoutOptions.url)
        ])
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        player.advanceToNextItem()
        expect(player.selectedMediaOption(for: .audible)).toEventually(equal(.disabled))
    }

    func testSelectedLegibleOptionWhenAdvancingToNextItem() {
        Self.setupLegibleSelectionTestWithAccessibilityDisplayType(.enabled(languageCode: "fr"))

        let player = Player(items: [
            .simple(url: Stream.onDemandWithOptions.url),
            .simple(url: Stream.onDemandWithoutOptions.url)
        ])
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("fr"))
        player.advanceToNextItem()
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.disabled))
    }

    func testSelectEnabledAudibleOption() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        expect(player.activeMediaOption(for: .audible)).to(haveLanguageIdentifier("fr"))
    }

    func testSelectAutomaticAudibleOptionDoesNothing() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .automatic, for: .audible)
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        expect(player.activeMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    func testSelectDisabledAudibleOptionDoesNothing() {
        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .disabled, for: .audible)
        expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        expect(player.activeMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    func testSelectEnabledLegibleOption() {
        Self.setupLegibleSelectionTestWithAccessibilityDisplayType(.disabled)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        expect(player.activeMediaOption(for: .legible)).to(haveLanguageIdentifier("ja"))
    }

    func testSelectAutomaticLegibleOption() {
        Self.setupLegibleSelectionTestWithAccessibilityDisplayType(.disabled)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .automatic, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        expect(player.activeMediaOption(for: .legible)).to(equal(.disabled))
    }

    func testSelectDisabledLegibleOption() {
        Self.setupLegibleSelectionTestWithAccessibilityDisplayType(.automatic)

        let player = Player(item: .simple(url: Stream.onDemandWithOptions.url))
        expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .disabled, for: .legible)
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.disabled))
        expect(player.activeMediaOption(for: .legible)).to(equal(.disabled))
    }

    // TODO: Try to select forced subtitles returned from activeMediaOption. Must do nothing
}

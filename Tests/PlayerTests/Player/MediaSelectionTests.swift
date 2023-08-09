//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

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
    override func setUp() {
        super.setUp()
        setupMediaAccessibilityType(.disabled)
    }

    private func setupMediaAccessibilityType(_ type: MediaAccessibilityDisplayType) {
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
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))
        expect(player.mediaSelectionOptions(for: .audible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
        expect(player.selectedMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
    }

    func testCharacteristicsAndOptionsWhenFailed() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    // TODO: testInitiallyEnabledAudibleOption when we implement initial setup

    func testInitiallyEnabledLegibleOption() {
        setupMediaAccessibilityType(.enabled(languageCode: "ja"))
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
    }

    func testInitiallyAutomaticLegibleOption() {
        setupMediaAccessibilityType(.automatic)
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
    }

    func testInitiallyDisabledLegibleOption() {
        setupMediaAccessibilityType(.disabled)
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.disabled))
    }

    // TODO:
    // - Test when switching between items in playlists
}

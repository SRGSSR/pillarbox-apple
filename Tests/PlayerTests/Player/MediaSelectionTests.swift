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
    private static func setupMediaAccessibilityType(_ type: MediaAccessibilityDisplayType) {
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

    private static func selectedMediaOption(
        forMediaCharacteristic characteristic: AVMediaCharacteristic,
        player: Player
    ) async throws -> AVMediaSelectionOption? {
        guard let item = player.queuePlayer.currentItem,
              let group = try await item.asset.loadMediaSelectionGroup(for: characteristic) else {
            return nil
        }
        return item.currentMediaSelection.selectedMediaOption(in: group)
    }

    override func setUp() {
        super.setUp()
        Self.setupMediaAccessibilityType(.disabled)
    }

    func testCharacteristicsAndOptionsWhenEmpty() {
        let player = Player()
        expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    @MainActor
    func testCharacteristicsAndOptionsWhenAvailable() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionCharacteristics).toEventually(equal([.audible, .legible]))
        expect(player.mediaSelectionOptions(for: .audible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).notTo(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
        expect(player.selectedMediaOption(for: .audible)).to(haveLanguageIdentifier("en"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(haveLanguageIdentifier("en"))
    }

    func testCharacteristicsAndOptionsWhenFailed() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.mediaSelectionCharacteristics).toAlways(beEmpty(), until: .seconds(2))
        expect(player.mediaSelectionOptions(for: .audible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .legible)).to(beEmpty())
        expect(player.mediaSelectionOptions(for: .visual)).to(beEmpty())
    }

    @MainActor
    func testInitiallyEnabledAudibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("en"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(haveLanguageIdentifier("en"))
    }

    @MainActor
    func testInitiallyEnabledLegibleOption() async throws {
        Self.setupMediaAccessibilityType(.enabled(languageCode: "ja"))
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(haveLanguageIdentifier("ja"))
    }

    @MainActor
    func testInitiallyAutomaticLegibleOption() async throws {
        Self.setupMediaAccessibilityType(.automatic)
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testInitiallyDisabledLegibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.disabled))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testSelectEnabledAudibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .audible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .audible).first { option in
            option.languageIdentifier == "fr"
        }!, for: .audible)
        await expect(player.selectedMediaOption(for: .audible)).toEventually(haveLanguageIdentifier("fr"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .audible, player: player)
        }.to(haveLanguageIdentifier("fr"))
    }

    func testSelectAutomaticAudibleOption() {
        // Should do nothing
    }

    func testSelectDisabledAudibleOption() {
        // Should do nothing
    }

    @MainActor
    func testSelectEnabledLegibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: player.mediaSelectionOptions(for: .legible).first { option in
            option.languageIdentifier == "ja"
        }!, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(haveLanguageIdentifier("ja"))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(haveLanguageIdentifier("ja"))
    }

    @MainActor
    func testSelectAutomaticLegibleOption() async throws {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .automatic, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.automatic))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(beNil())
    }

    @MainActor
    func testSelectDisabledLegibleOption() async throws {
        Self.setupMediaAccessibilityType(.automatic)
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        await expect(player.mediaSelectionOptions(for: .legible)).toEventuallyNot(beEmpty())

        player.select(mediaOption: .disabled, for: .legible)
        await expect(player.selectedMediaOption(for: .legible)).toEventually(equal(.disabled))
        await expect {
            try await Self.selectedMediaOption(forMediaCharacteristic: .legible, player: player)
        }.to(beNil())
    }

    // TODO:
    // - Test when switching between items in playlists
    // - Test selection for non-available option (no-op)
}
